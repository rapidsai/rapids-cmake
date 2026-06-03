# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/export/export.cmake)

cmake_minimum_required(VERSION 4.0)
project(FakEProJecT LANGUAGES CXX VERSION 3.1.4)

add_library(fakeLib INTERFACE)
add_library(fakeRenamed INTERFACE)
set_target_properties(fakeRenamed PROPERTIES EXPORT_NAME renamed)
install(TARGETS fakeLib fakeRenamed EXPORT fake_set)

rapids_export(BUILD FakEProJecT
              GLOBAL_TARGETS
              EXPORT_SET fake_set
              LANGUAGES CXX
              NAMESPACE test::)

file(WRITE "${CMAKE_BINARY_DIR}/verify/CMakeLists.txt"
     [=[
cmake_minimum_required(VERSION 4.0)
project(verify_build_targets LANGUAGES CXX)

set(FakEProJecT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../")
find_package(FakEProJecT REQUIRED)

foreach(target IN ITEMS test::fakeLib test::renamed)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "rapids_export failed to generate ${target}")
  endif()

  get_target_property(_is_global ${target} IMPORTED_GLOBAL)
  if(NOT _is_global)
    message(FATAL_ERROR "rapids_export(GLOBAL_TARGETS) failed to mark ${target} as global")
  endif()
endforeach()
]=])

add_custom_target(verify_target_file ALL
                  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/verify/build"
                  COMMAND ${CMAKE_COMMAND} -S="${CMAKE_BINARY_DIR}/verify"
                          -B="${CMAKE_BINARY_DIR}/verify/build")
