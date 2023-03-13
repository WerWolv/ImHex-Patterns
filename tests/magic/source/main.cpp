#include <wolv/io/file.hpp>
#include <wolv/utils/guards.hpp>

#include <fmt/format.h>
#include <cstdlib>

#include <magic.h>

#define EXIT_SKIP 77

int main(int argc, char **argv) {
    // Any number of arguments other than 3 are invalid
    if (argc != 3)
        return EXIT_FAILURE;

    // Extract command line arguments
    const std::string magicName       = argv[1];
    const std::fs::path magicFilePath = argv[2];

    fmt::print("Running test {} on test file {}\n", magicName, magicFilePath.filename().string());

    magic_t ctx = magic_open(MAGIC_NONE);
    ON_SCOPE_EXIT { magic_close(ctx); };

    if (ctx == nullptr)
        return EXIT_FAILURE;

    if (magic_compile(ctx, magicFilePath.string().c_str()) != 0) {
        fmt::print("Error during compilation: {}\n", magic_error(ctx));
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}