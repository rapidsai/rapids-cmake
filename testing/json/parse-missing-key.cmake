# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/parse.cmake)

rapids_json_parse(p STRING [=[{ "a" : { "b" : 1 } }]=] KEY missing VALUES b)
