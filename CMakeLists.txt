#
# CMakeLists.txt
#
# Copyright (c) 2024 Mateusz Stadnik <matgla@live.com>
#
# Distributed under the terms of the MIT License.
#

cmake_minimum_required(VERSION 3.30)

# language detection must be done after toolchain detection
project (yasehal NONE)

enable_language(CXX)

set (CMAKE_CXX_STANDARD 26)
set (CMAKE_EXPORT_COMPILE_COMMANDS ON)
set (CMAKE_CXX_STANDARD_REQUIRED YES)
set (CMAKE_CXX_EXTENSIONS OFF)
set (CMAKE_CXX_FLAGS "-fmodules")
set (CLANG_DEFAULT_CXX_STDLIB=libc++)
set (CMAKE_CXX_COMPILER_IMPORT_STD ON)
set (CMAKE_CXX_SCAN_FOR_MODULES ON)
option (ENABLE_EXAMPLES "Enable HAL examples" ON)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)

add_subdirectory(interface)
add_subdirectory(source/x86_host)

message(STATUS "${ENABLE_EXAMPLES}")

if (${ENABLE_EXAMPLES})
  add_subdirectory(examples)
endif ()
