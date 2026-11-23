# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(consumer LANGUAGES NONE)

file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/calls.txt")
set(args)
if(required)
  list(APPEND args REQUIRED)
endif()
if(quiet)
  list(APPEND args QUIET)
endif()
find_package(Parent ${args})

if(scenario MATCHES "^missing")
  if(Parent_FOUND OR NOT Parent_NOT_FOUND_MESSAGE MATCHES "Dependency")
    message(FATAL_ERROR "A missing dependency did not mark the parent package as unavailable")
  endif()
elseif(NOT Parent_FOUND OR NOT Dependency_FOUND)
  message(FATAL_ERROR "Failed to find the parent and dependency packages")
endif()
