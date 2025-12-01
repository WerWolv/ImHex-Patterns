cmake_minimum_required(VERSION 3.16)

project(ImHex-Patterns)

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

    if (NOT DEFINED DIMHEX_PATTERNS_LIBPL_GIT_REPO OR DIMHEX_PATTERNS_LIBPL_GIT_REPO STREQUAL "")
        set(LIBPL_GIT_REPO "https://github.com/WerWolv/PatternLanguage")
    else()
        set(LIBPL_GIT_REPO ${DIMHEX_PATTERNS_LIBPL_GIT_REPO})
    endif()

    if (NOT DEFINED IMHEX_PATTERNS_LIBPL_GIT_HASH OR IMHEX_PATTERNS_LIBPL_GIT_HASH STREQUAL "")
        set(LIBPL_GIT_TAG "master")
    else()
        set(LIBPL_GIT_TAG ${IMHEX_PATTERNS_LIBPL_GIT_HASH})
    endif()

    FetchContent_Declare(
        pattern_language
        GIT_REPOSITORY      ${LIBPL_GIT_REPO}
        GIT_TAG             ${LIBPL_GIT_TAG}
    )

    FetchContent_MakeAvailable(pattern_language)
endif()

if(IMHEX_PATTERNS_ENABLE_UNIT_TESTS)
    add_subdirectory(tests)
endif()