# EOOS WIN32.
#
# @author    Sergey Baigudin, sergey@baigudin.software
# @copyright 2019-2020, Sergey Baigudin, Baigudin Software

cmake_minimum_required(VERSION 3.15)
project(eoos-if-win32 VERSION 1.0.0 LANGUAGES CXX)

include(cmake/eoos.cmake)
message(STATUS "EOOS option EOOS_ENABLE_TESTS=" ${EOOS_ENABLE_TESTS})
enable_testing()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:__cplusplus" CACHE STRING "" FORCE)

add_subdirectory(extern)
add_subdirectory(codebase)
