cmake_minimum_required(VERSION 3.16)

project(patterns_tests)

set(TOP_LEVEL "${CMAKE_CURRENT_SOURCE_DIR}/../..")

file(GLOB PATTERNS
    "${TOP_LEVEL}/patterns/*.hexpat"
)

set(PATTERN_INCLUDES "${TOP_LEVEL}/includes")

add_executable(patterns_tests
        source/main.cpp
)

target_include_directories(patterns_tests PRIVATE include)
target_link_libraries(patterns_tests PRIVATE libpl fmt::fmt-header-only)

set_target_properties(patterns_tests PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

foreach (pattern IN LISTS PATTERNS)
    get_filename_component(PATTERN_NAME ${pattern} NAME)

    file(GLOB TEST_FILES "${CMAKE_CURRENT_SOURCE_DIR}/test_data/${PATTERN_NAME}/*")
    if (NOT TEST_FILES)
        file(GLOB TEST_FILES "${CMAKE_CURRENT_SOURCE_DIR}/test_data/${PATTERN_NAME}.*")
        list(SUBLIST TEST_FILES 0 1 TEST_FILES)
    endif ()

    if (TEST_FILES)
        foreach (TEST_FILE IN LISTS TEST_FILES)
            get_filename_component(TEST_FILENAME ${TEST_FILE} NAME)
            set(TEST_NAME "Patterns/${PATTERN_NAME}/${TEST_FILENAME}")
            add_test(NAME ${TEST_NAME} COMMAND patterns_tests "${PATTERN_NAME}" "${pattern}" "${PATTERN_INCLUDES}" "${TEST_FILE}" WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
            set_tests_properties(${TEST_NAME} PROPERTIES SKIP_RETURN_CODE 77)
        endforeach ()
    else ()
        set(TEST_NAME "Patterns/${PATTERN_NAME}")
        add_test(NAME ${TEST_NAME} COMMAND patterns_tests "${PATTERN_NAME}" "${pattern}" "${PATTERN_INCLUDES}" WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
        set_tests_properties(${TEST_NAME} PROPERTIES SKIP_RETURN_CODE 77)
    endif ()
endforeach ()
