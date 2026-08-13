# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0 FATAL_ERROR)

project(write_language-CMP0220 LANGUAGES CXX)

cmake_policy(SET CMP0220 NEW)

add_subdirectory(A)

add_executable(write_language-CMP0220 main.cpp)
target_link_libraries(write_language-CMP0220 PRIVATE A)

cmake_language(DEFER GET_CALL_IDS all_ids)
list(LENGTH all_ids list_len)
if(NOT list_len EQUAL 1)
  message(FATAL_ERROR "Language hooks detected when CMP0220 is set to NEW: ${all_ids}")
endif()
