cmake_minimum_required(VERSION 3.16)

project(tests)

set(CMAKE_CXX_STANDARD 20)

add_subdirectory(lib/pl)

enable_testing()

add_subdirectory(patterns)