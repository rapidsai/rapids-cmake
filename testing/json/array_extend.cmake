# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/array_extend.cmake)

function(test_array_extend expected_result array values)
  rapids_json_array_extend(actual_result "${array}" "${values}")
  string(JSON equal EQUAL "${expected_result}" "${actual_result}")
  if(NOT equal)
    string(REPLACE "\n" "\n  " formatted_expected_result "${expected_result}")
    string(REPLACE "\n" "\n  " formatted_actual_result "${actual_result}")
    message(SEND_ERROR "Expected result:\n  ${formatted_expected_result}\nActual result:\n  ${formatted_actual_result}"
    )
  endif()
endfunction()

test_array_extend("[1]" "[]" "[1]")
test_array_extend("[0, 1]" "[0]" "[1]")
test_array_extend("[0, 1, 2]" "[0, 1]" "[2]")
test_array_extend("[0, 1]" "[0, 1]" "[]")
test_array_extend("[0, 1, 2, 3, 5]" "[0, 1]" "[2, 3, 5]")
test_array_extend([==[[0, "", false, null, 1, "str", true, null]]==] [==[[0, "", false, null]]==]
                  [==[[1, "str", true, null]]==])
