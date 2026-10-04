# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/write_git_revision_file.cmake)

cmake_minimum_required(VERSION 4.0)

project(DEMO LANGUAGES CXX)
rapids_cmake_write_git_revision_file(demo_version "demo_git_version.hpp")
rapids_cmake_write_git_revision_file(nested_version "nested headers/nested_git_version.hpp"
                                     PREFIX NESTED)

add_custom_target(verify_relative_headers ALL
                  COMMAND ${CMAKE_COMMAND} -DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
                          -DBINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} -P
                          ${CMAKE_CURRENT_SOURCE_DIR}/verify_headers.cmake)
add_dependencies(verify_relative_headers demo_version_compute_git_info
                 nested_version_compute_git_info)

add_executable(write_git_version main.cpp)
target_link_libraries(write_git_version PRIVATE demo_version nested_version)
add_dependencies(write_git_version verify_relative_headers)
target_compile_features(write_git_version PRIVATE cxx_std_14)
