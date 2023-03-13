cmake_minimum_required(VERSION 3.16)

project(magic_test)

set(TOP_LEVEL "${CMAKE_CURRENT_SOURCE_DIR}/../..")

set(MAGIC_FOLDER "${TOP_LEVEL}/magic")
file(GLOB MAGIC_FILES
    "${MAGIC_FOLDER}/*"
)

add_executable(magic_test
        source/main.cpp
)

find_package(PkgConfig REQUIRED)
pkg_search_module(MAGIC libmagic>=5.39)

target_include_directories(magic_test PRIVATE include)
target_link_libraries(magic_test PRIVATE libpl magic fmt::fmt-header-only)

set_target_properties(magic_test PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

foreach (magic_file IN LISTS MAGIC_FILES)
    file(RELATIVE_PATH MAGIC_NAME ${MAGIC_FOLDER} ${magic_file})

    set(TEST_NAME "Magic/${MAGIC_NAME}")

    add_test(NAME ${TEST_NAME} COMMAND magic_test "${MAGIC_NAME}" "${magic_file}" WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    set_tests_properties(${TEST_NAME} PROPERTIES SKIP_RETURN_CODE 77)
endforeach ()