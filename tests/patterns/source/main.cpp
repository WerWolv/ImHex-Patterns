#include <pl.hpp>
#include <helpers/file.hpp>

#include <fmt/format.h>
#include <cstdlib>

#define EXIT_SKIP 77

int main(int argc, char **argv) {
    // If only 4 arguments have been provided, then no test file was provided. Skip the test in that case
    if (argc == 4)
        return EXIT_SKIP;

    // Any number of arguments other than 5 are invalid
    if (argc != 5)
        return EXIT_FAILURE;

    // Extract command line arguments
    const std::string patternName       = argv[1];
    const std::fs::path patternFilePath = argv[2];
    const std::fs::path includePath     = argv[3];
    const std::fs::path testFilePath    = argv[4];

    if (testFilePath.empty())
        return EXIT_SKIP;

    fmt::print("Running test {} on test file {}\n", patternName, testFilePath.stem().string());

    // Open pattern file
    pl::fs::File patternFile(patternFilePath, pl::fs::File::Mode::Read);
    if (!patternFile.isValid())
        return EXIT_FAILURE;

    // Open test file
    pl::fs::File testFile(testFilePath, pl::fs::File::Mode::Read);
    if (!testFile.isValid())
        return EXIT_FAILURE;

    // Setup Pattern Language Runtime
    pl::PatternLanguage runtime;
    {
        constexpr auto DummyPragmaHandler = [](const auto&, const auto&){ return true; };

        runtime.setDataSource([&](pl::u64 address, pl::u8 *data, size_t size) {
            testFile.seek(address);
            testFile.readBuffer(data, size);
        }, 0x00, testFile.getSize());
        runtime.setDangerousFunctionCallHandler([]{ return true; });
        runtime.setIncludePaths({ includePath });
        runtime.addPragma("MIME", DummyPragmaHandler);
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