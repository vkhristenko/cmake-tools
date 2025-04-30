cmake_minimum_required(VERSION 3.26)
project(test_add_dependency)

add_executable(test0 test0.cpp)
add_executable(test1 test1.cpp)
add_executable(test2 test2.cpp)
add_library(test3 test3.cpp)
add_dependencies(test2 test1 test0 test3)
