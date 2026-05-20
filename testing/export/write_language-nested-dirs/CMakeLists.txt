# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/export/write_language.cmake)

cmake_minimum_required(VERSION 4.0 FATAL_ERROR)

project(write_language-nested-dirs LANGUAGES NONE)

# verify that enabling langues CUDA in A/B allows us to build targets that use CUDA
add_subdirectory(A)

add_executable(write_language-nested-dirs main.cu)
target_link_libraries(write_language-nested-dirs PRIVATE A B)
