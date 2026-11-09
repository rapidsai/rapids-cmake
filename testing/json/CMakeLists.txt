# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

add_cmake_config_test(array_append.cmake)
add_cmake_config_test(array_append-dict.cmake SHOULD_FAIL "array argument must be an array")
add_cmake_config_test(array_append-leaf.cmake SHOULD_FAIL "array argument must be an array")

add_cmake_config_test(array_extend.cmake)
add_cmake_config_test(array_extend-dict.cmake SHOULD_FAIL "array argument must be an array")
add_cmake_config_test(array_extend-leaf.cmake SHOULD_FAIL "array argument must be an array")
add_cmake_config_test(array_extend-with-dict.cmake SHOULD_FAIL "values argument must be an array")
add_cmake_config_test(array_extend-with-leaf.cmake SHOULD_FAIL "values argument must be an array")

add_cmake_config_test(compute_matrix_product)

add_cmake_config_test(array_items.cmake)
add_cmake_config_test(array_items-invalid-json.cmake SHOULD_FAIL "is not valid JSON")
add_cmake_config_test(array_items-invalid-value.cmake SHOULD_FAIL "to be an array")
add_cmake_config_test(array_items-missing-file.cmake SHOULD_FAIL "does not exist")
add_cmake_config_test(array_items-missing-key.cmake SHOULD_FAIL "to be an array")

add_cmake_config_test(parse.cmake)
add_cmake_config_test(parse-paths.cmake)
add_cmake_config_test(parse-duplicate-key.cmake SHOULD_FAIL "keys can only be declared once")
add_cmake_config_test(parse-file-and-string-modes.cmake SHOULD_FAIL "both FILE and STRING")
add_cmake_config_test(parse-invalid-json.cmake SHOULD_FAIL "is not valid JSON")
add_cmake_config_test(parse-missing-file.cmake SHOULD_FAIL "does not exist")
add_cmake_config_test(parse-missing-key.cmake SHOULD_FAIL "could not find KEY 'missing'")
add_cmake_config_test(parse-no-source.cmake SHOULD_FAIL "requires one of FILE or STRING")
add_cmake_config_test(parse-relative-base-dir.cmake SHOULD_FAIL "must be an absolute path")
