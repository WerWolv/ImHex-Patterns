cmake_minimum_required(VERSION 3.16)

project(tests)

set(CMAKE_CXX_STANDARD 20)

include(FetchContent)

FetchContent_Declare(
    pattern_language
    GIT_REPOSITORY      https://github.com/WerWolv/PatternLanguage
    GIT_TAG             master
)

FetchContent_MakeAvailable(pattern_language)

enable_testing()

add_subdirectory(patterns)
add_subdirectory(includes)

add_custom_target(test_all DEPENDS patterns_tests includes_test)