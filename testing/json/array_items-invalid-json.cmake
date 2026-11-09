# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/array_items.cmake)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/doc.json [=[{ "a" : ]=])
rapids_json_array_items(items FILE ${CMAKE_CURRENT_BINARY_DIR}/doc.json)
