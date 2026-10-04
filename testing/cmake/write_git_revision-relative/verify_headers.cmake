# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

foreach(header IN ITEMS demo_git_version.hpp "nested headers/nested_git_version.hpp")
  if(NOT EXISTS "${BINARY_DIR}/${header}")
    message(FATAL_ERROR "Git revision header was not generated in the build directory: ${header}")
  endif()
  if(EXISTS "${SOURCE_DIR}/${header}")
    message(FATAL_ERROR "Git revision header was generated in the source directory: ${header}")
  endif()
endforeach()
