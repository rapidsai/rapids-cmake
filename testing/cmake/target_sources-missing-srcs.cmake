# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/target_sources.cmake)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/no_srcs.json [=[{ "other" : [] }]=])

add_custom_target(input)
rapids_cmake_target_sources(input JSON ${CMAKE_CURRENT_BINARY_DIR}/no_srcs.json)
