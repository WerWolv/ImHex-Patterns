#include <pl.hpp>

#include <wolv/io/file.hpp>

#include <fmt/format.h>
#include <cstdlib>

#define EXIT_SKIP 77

int main(int argc, char **argv) {
    // Any number of arguments other than 4 are invalid
    if (argc != 4)
        return EXIT_FAILURE;

    // Extract command line arguments
    const std::string includeName       = argv[1];
    const std::fs::path includeFilePath = argv[2];
    const std::fs::path includePath     = argv[3];

    fmt::print("Running test {} on test file {}\n", includeName, includeFilePath.filename().string());

    // Open pattern file
    wolv::io::File patternFile(includeFilePath, wolv::io::File::Mode::Read);
    if (!patternFile.isValid())
        return EXIT_FAILURE;

    // Setup Pattern Language Runtime
    pl::PatternLanguage runtime;
    {
        constexpr auto DummyPragmaHandler = [](const auto&, const auto&) {
            return false;
        };

        runtime.setDataSource(0x00, 0x100000,
            [&](pl::u64 address, pl::u8 *data, size_t size) {
                pl::core::err::E0011.throwError("Include files should never read from memory directly!");
            }
        );
        runtime.setDangerousFunctionCallHandler([]{ return true; });
        runtime.setIncludePaths({ includePath });

        runtime.addPragma("endian",         DummyPragmaHandler);
        runtime.addPragma("MIME",           DummyPragmaHandler);
        runtime.addPragma("base_address",   DummyPragmaHandler);
        runtime.addPragma("eval_depth",     DummyPragmaHandler);
        runtime.addPragma("array_limit",    DummyPragmaHandler);
        runtime.addPragma("pattern_limit",  DummyPragmaHandler);

        runtime.addDefine("__PL_UNIT_TESTS__");

        runtime.setLogCallback([](auto level, const std::string &message) {
            switch (level) {
                using enum pl::core::LogConsole::Level;
                case Debug:      fmt::print("    [DEBUG] "); break;
                case Info:       fmt::print("    [INFO]  "); break;
                case Warning:    fmt::print("    [WARN]  "); break;
                case Error:      fmt::print("    [ERROR] "); break;
            }

            fmt::print("{}\n", message);
        });
    }

    // Execute pattern
    if (!runtime.executeString(patternFile.readString(), "<Source Code>")) {
        fmt::print("Error during execution!\n");

        if (const auto &hardError = runtime.getEvalError(); hardError.has_value())
            fmt::print("Hard error: {}:{} - {}\n\n", hardError->line, hardError->column, hardError->message);

        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
