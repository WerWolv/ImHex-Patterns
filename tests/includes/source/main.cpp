#include <pl.hpp>
#include <helpers/file.hpp>

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
    pl::fs::File patternFile(includeFilePath, pl::fs::File::Mode::Read);
    if (!patternFile.isValid())
        return EXIT_FAILURE;

    // Setup Pattern Language Runtime
    pl::PatternLanguage runtime;
    {
        constexpr auto DummyPragmaHandler = [](const auto&, const auto&){ pl::LogConsole::abortEvaluation("Include files should never use this pragma!"); return true; };

        runtime.setDataSource([&](pl::u64 address, pl::u8 *data, size_t size) {
            pl::LogConsole::abortEvaluation("Include files should never read from memory directly!");
        }, 0x00, 0x100000);
        runtime.setDangerousFunctionCallHandler([]{ return true; });
        runtime.setIncludePaths({ includePath });

        runtime.addPragma("endian",         DummyPragmaHandler);
        runtime.addPragma("MIME",           DummyPragmaHandler);
        runtime.addPragma("base_address",   DummyPragmaHandler);
        runtime.addPragma("eval_depth",     DummyPragmaHandler);
        runtime.addPragma("array_limit",    DummyPragmaHandler);
        runtime.addPragma("pattern_limit",  DummyPragmaHandler);
    }

    // Execute pattern
    if (!runtime.executeString(patternFile.readString())) {
        fmt::print("Error during execution!\n");

        if (const auto &hardError = runtime.getError(); hardError.has_value())
            fmt::print("Hard error: {}\n\n", hardError.value().what());

        for (const auto &[level, message] : runtime.getConsoleLog()) {
            switch (level) {
                case pl::LogConsole::Level::Debug:      fmt::print("    [DEBUG] "); break;
                case pl::LogConsole::Level::Info:       fmt::print("    [INFO]  "); break;
                case pl::LogConsole::Level::Warning:    fmt::print("    [WARN]  "); break;
                case pl::LogConsole::Level::Error:      fmt::print("    [ERROR] "); break;
            }

            fmt::print("{}\n", message);
        }

        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}