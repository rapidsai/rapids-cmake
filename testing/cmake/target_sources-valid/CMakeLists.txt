# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/target_sources.cmake)

cmake_minimum_required(VERSION 4.0)

project(DEMO VERSION 2.4 LANGUAGES CXX)

add_library(input SHARED)
rapids_cmake_target_sources(input JSON ./srcs.json)

# Validate that `input` has the correct SOURCES property
get_target_property(actual_srcs input SOURCES)
set(expected_srcs "${CMAKE_CURRENT_SOURCE_DIR}/srcs/a.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/srcs/b.cpp"
                  "${CMAKE_CURRENT_SOURCE_DIR}/srcs/c.cpp")
if(NOT actual_srcs STREQUAL "${expected_srcs}")
  message(FATAL_ERROR "rapids_cmake_target_sources set unexpected SOURCES:\n  ${actual_srcs}\nexpected:\n  ${expected_srcs}"
  )
endif()

# Validate the sources are PRIVATE and don't propagate to consumers
get_target_property(interface_srcs input INTERFACE_SOURCES)
if(interface_srcs)
  message(FATAL_ERROR "rapids_cmake_target_sources must add PRIVATE sources, found INTERFACE_SOURCES: ${interface_srcs}"
  )
endif()

# Validate that sources are appended to existing ones
add_library(existing SHARED srcs/a.cpp)
rapids_cmake_target_sources(existing JSON srcs.json)
get_target_property(existing_srcs existing SOURCES)
list(LENGTH existing_srcs existing_len)
if(NOT existing_len EQUAL 4)
  message(FATAL_ERROR "rapids_cmake_target_sources should append to existing SOURCES, found: ${existing_srcs}"
  )
endif()
