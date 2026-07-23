# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/write_version_file.cmake)

cmake_minimum_required(VERSION 4.0)

project(RandomProjectName VERSION 3.2.1 LANGUAGES NONE)
rapids_cmake_write_version_file(no_combined.hpp PREFIX NO_COMBINED NO_COMBINED_VERSION_MACRO)
rapids_cmake_write_version_file(combined.hpp PREFIX COMBINED)

enable_language(CXX)
add_executable(write_version main.cpp)
target_include_directories(write_version PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
target_compile_features(write_version PRIVATE cxx_std_14)
