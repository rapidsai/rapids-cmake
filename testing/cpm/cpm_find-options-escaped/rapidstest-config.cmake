# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
@PACKAGE_INIT@

cmake_minimum_required(VERSION 4.0)

include("${CMAKE_CURRENT_LIST_DIR}/rapidstest-config-version.cmake")

add_library(RapidsTest::RapidsTest IMPORTED INTERFACE GLOBAL)

check_required_components(RapidsTest)
