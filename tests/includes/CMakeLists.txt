cmake_minimum_required(VERSION 3.16)

project(includes_test)

set(TOP_LEVEL "${CMAKE_CURRENT_SOURCE_DIR}/../..")

file(GLOB INCLUDES
    "${TOP_LEVEL}/includes/*/*.pat"
)

set(PATTERN_INCLUDES "${TOP_LEVEL}/includes")

add_executable(includes_test
        source/main.cpp
)

target_include_directories(includes_test PRIVATE include)
target_link_libraries(includes_test libpl)

set_target_properties(includes_test PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

foreach (include IN LISTS INCLUDES)
    file(RELATIVE_PATH INCLUDE_NAME ${PATTERN_INCLUDES} ${include})

    set(TEST_NAME "Includes/${INCLUDE_NAME}")

    add_test(NAME ${TEST_NAME} COMMAND includes_test "${INCLUDE_NAME}" "${include}" "${PATTERN_INCLUDES}" WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    set_tests_properties(${TEST_NAME} PROPERTIES SKIP_RETURN_CODE 77)
endforeach ()