# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/parse.cmake)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/invalid.json [=[{ "a" : ]=])
rapids_json_parse(p FILE ${CMAKE_CURRENT_BINARY_DIR}/invalid.json VALUES a)
