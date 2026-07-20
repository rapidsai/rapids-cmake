# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/array_append.cmake)

function(test_array_append expected_result array value)
  rapids_json_array_append(actual_result "${array}" "${value}")
  string(JSON equal EQUAL "${expected_result}" "${actual_result}")
  if(NOT equal)
    string(REPLACE "\n" "\n  " formatted_expected_result "${expected_result}")
    string(REPLACE "\n" "\n  " formatted_actual_result "${actual_result}")
    message(SEND_ERROR "Expected result:\n  ${formatted_expected_result}\nActual result:\n  ${formatted_actual_result}"
    )
  endif()
endfunction()

test_array_append("[1]" "[]" "1")
test_array_append("[0, 1]" "[0]" "1")
test_array_append("[0, 1, 2]" "[0, 1]" "2")
test_array_append([==[[0, "str"]]==] "[0]" [==["str"]==])
test_array_append("[0, true]" "[0]" "true")
test_array_append("[0, null]" "[0]" "null")
test_array_append("[0, [1, 2]]" "[0]" "[1, 2]")
