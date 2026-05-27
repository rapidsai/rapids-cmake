# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

add_cmake_config_test(array_append.cmake)

add_cmake_config_test(array_extend.cmake)
add_cmake_config_test(array_extend-with-dict.cmake SHOULD_FAIL "values argument must be an array")
add_cmake_config_test(array_extend-with-leaf.cmake SHOULD_FAIL "values argument must be an array")

add_cmake_config_test(compute_matrix_product)
