# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0 FATAL_ERROR)

project(write_language-CMP0220 LANGUAGES NONE)

include(${rapids-cmake-dir}/export/write_language.cmake)

cmake_policy(SET CMP0220 NEW)

set(path "${CMAKE_CURRENT_BINARY_DIR}/enable_cuda.cmake")
rapids_export_write_language(BUILD CUDA "${path}")

add_custom_target(check_write_language_CMP0220 ALL COMMAND ${CMAKE_COMMAND} --log-level=DEBUG -P
                                                           "${path}")
