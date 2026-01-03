#include <pl.hpp>

#include <wolv/io/file.hpp>

#include <fmt/format.h>
#include <wolv/utils/string.hpp>
#include <cstdlib>

#include <pl/patterns/pattern.hpp>

#define EXIT_SKIP 77

bool validatePatternValues(pl::ptrn::Pattern *pattern) {
    auto value = pattern->getFormattedValue();
    if (!pattern->hasValidFormattedValue()) {
        fmt::print("Invalid formatted value \"{}\" of pattern \"{}\"\n", value, pattern->getDisplayName());
        return false;
    }

    for (const auto &[address, child] : pattern->getChildren()) {
        if (pattern == child)
            continue;

        child->setOffset(address);
        if (!validatePatternValues(child))
            return false;
    }

    return true;
}

int main(int argc, char **argv) {
    // Any number of arguments other than 5 are invalid
    if (argc != 4 && argc != 5)
        return EXIT_FAILURE;

    bool hasTestFile = argc == 5;

    // Extract command line arguments
    const std::string patternName       = argv[1];
    const std::fs::path patternFilePath = argv[2];
    const std::fs::path includePath     = argv[3];
    const std::fs::path testFilePath    = hasTestFile ? argv[4] : "";

    // Open pattern file
    wolv::io::File patternFile(patternFilePath, wolv::io::File::Mode::Read);
    if (!patternFile.isValid())
        return EXIT_FAILURE;

    // Setup Pattern Language Runtime
    pl::PatternLanguage runtime;
    bool hasDescription = false;
    {
        constexpr auto DummyPragmaHandler = [](const auto&, const auto&){ return true; };
        auto DescPragmaHandler = [&hasDescription](const auto&, const auto&){
            hasDescription = true;
            return true;
        };

        if (hasTestFile) {
            // Open test file
            static wolv::io::File testFile(testFilePath, wolv::io::File::Mode::Read);
            if (!testFile.isValid())
                return EXIT_FAILURE;

            runtime.setDataSource(0x00, testFile.getSize(),
                [&](pl::u64 address, pl::u8 *data, size_t size) {
                    testFile.seek(address);
                    testFile.readBuffer(data, size);
                }
            );
        }

        runtime.setDangerousFunctionCallHandler([]{ return true; });
        runtime.setIncludePaths({ includePath, patternFilePath.parent_path() });
        runtime.addPragma("MIME", DummyPragmaHandler);
        runtime.addPragma("description", DescPragmaHandler);
        runtime.addDefine("__PL_UNIT_TESTS__");

        runtime.setLogCallback([](auto level, const std::string &message) {
            switch (level) {
                using enum pl::core::LogConsole::Level;
                case Debug:      fmt::print("    [DEBUG] "); break;
                case Info:       fmt::print("    [INFO]  "); break;
                case Warning:    fmt::print("    [WARN]  "); break;
                case Error:      fmt::print("    [ERROR] "); break;
                default: break;
            }

            fmt::println("{}", message);
        });
    }

    if (hasTestFile) {
        // Execute pattern
        fmt::println("Executing pattern {} using test file {}", patternName, wolv::util::toUTF8String(testFilePath.filename()));

        auto exitCode = runtime.executeString(patternFile.readString(), "<Source Code>");
        if (exitCode != 0) {
            fmt::println("Non-zero exit code returned from execution. (Exit Code: {})!", exitCode);

            if (const auto &compileErrors = runtime.getCompileErrors(); !compileErrors.empty()) {
                for (const auto &error : compileErrors) {
                    fmt::println("{}", error.format());
                }
            } else if (const auto &evalError = runtime.getEvalError(); evalError.has_value()) {
                fmt::println("{}:{}  {}", evalError->line, evalError->column, evalError->message);
            }

            return exitCode;
        }

        for (const auto &pattern : runtime.getPatterns()) {
            if (!validatePatternValues(pattern.get()))
                return EXIT_FAILURE;
        }
        for (const auto &[id, section] : runtime.getSections()) {
            for (const auto &pattern : runtime.getPatterns(id)) {
                if (!validatePatternValues(pattern.get()))
                    return EXIT_FAILURE;
            }
        }
    } else {
        // Parse the file
        fmt::println("Parsing pattern {} without executing it", patternName);
        const auto ast = runtime.parseString(patternFile.readString(), "<Source Code>");
        if (!ast.has_value()) {
            fmt::println("Error when parsing pattern!");

            if (const auto &compileErrors = runtime.getCompileErrors(); !compileErrors.empty()) {
                for (const auto &error : compileErrors) {
                    fmt::println("{}", error.format());
                }
            }

            return EXIT_FAILURE;
        }

        if (ast->empty()) {
            fmt::println("Pattern {} produced no AST", patternName);
            return EXIT_FAILURE;
        }
    }

    if (!hasDescription) {
        fmt::print("No description pragma found in pattern file\n");
        fmt::print("Please add a #pragma description <your description> tag to the pattern!\n");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
