cmake_minimum_required(VERSION 3.16)

option(IMHEX_PATTERNS_ENABLE_UNIT_TESTS "Enable building unit tests for ImHex-Patterns"          OFF)

# if enabled, add a unit_test custom target for all the unit tests to be registered against
if(IMHEX_PATTERNS_ENABLE_UNIT_TESTS)
    if(NOT TARGET unit_tests)
        enable_testing()
        add_custom_target(unit_tests)
    endif()
endif()

# If this has been manually cloned into another project, libpl may already have been set up
if(NOT TARGET libpl)
    include(FetchContent)

    FetchContent_Declare(
        pattern_language
        GIT_REPOSITORY      https://github.com/WerWolv/PatternLanguage
        GIT_TAG             master
    )

    FetchContent_MakeAvailable(pattern_language)
endif()

if(IMHEX_PATTERNS_ENABLE_UNIT_TESTS)
    add_subdirectory(tests)
endif()