# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.3)
project(compute_json_matrix_product NONE)

function(test_compute_json_matrix_product)
  set(options)
  set(one_value EXPECTED_PRODUCT EXPECTED_EXIT_CODE EXPECTED_STDERR)
  set(multi_value ARGS)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED _RAPIDS_EXPECTED_EXIT_CODE)
    set(_RAPIDS_EXPECTED_EXIT_CODE 0)
  endif()
  if(NOT DEFINED _RAPIDS_EXPECTED_STDERR)
    set(_RAPIDS_EXPECTED_STDERR "^$")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} "-DARGS=${_RAPIDS_ARGS}"
                          "-DEXPECTED_PRODUCT=${_RAPIDS_EXPECTED_PRODUCT}"
                          "-Drapids-cmake-dir=${rapids-cmake-dir}" -P
                          "${CMAKE_CURRENT_SOURCE_DIR}/test_compute_json_matrix_product.cmake"
                  RESULT_VARIABLE actual_exit_code
                  ERROR_VARIABLE actual_stderr)

  if(NOT actual_exit_code EQUAL _RAPIDS_EXPECTED_EXIT_CODE)
    message(SEND_ERROR "Expected exit code ${_RAPIDS_EXPECTED_EXIT_CODE}, got ${actual_exit_code}")
  endif()
  string(REGEX REPLACE "\n*$" "" expected_stderr "${_RAPIDS_EXPECTED_STDERR}")
  string(REGEX REPLACE "\n*$" "" actual_stderr "${actual_stderr}")
  if(NOT actual_stderr MATCHES "${expected_stderr}")
    string(REPLACE "\n" "\n  " formatted_expected_stderr "${expected_stderr}")
    string(REPLACE "\n" "\n  " formatted_actual_stderr "${actual_stderr}")
    message(FATAL_ERROR "Expected stderr:\n  ${formatted_expected_stderr}\nActual stderr:\n  ${formatted_actual_stderr}"
    )
  endif()
endfunction()

# Test that string reading works
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[{
    "a": [1, 2],
    "b": [3, 4]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"a": 1, "b": 3},
    {"a": 1, "b": 4},
    {"a": 2, "b": 3},
    {"a": 2, "b": 4}
  ]]==])

# Test that file reading works
test_compute_json_matrix_product(
  ARGS
  MATRIX_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/file_test.json"
  EXPECTED_PRODUCT
  [==[[
    {"a": 1, "b": 3},
    {"a": 1, "b": 4},
    {"a": 2, "b": 3},
    {"a": 2, "b": 4}
  ]]==])

# Test that at least one of string or file is required
test_compute_json_matrix_product(
  EXPECTED_EXIT_CODE
  1
  EXPECTED_STDERR
  [==[^CMake Error at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Must specify at least one of MATRIX_STRING or MATRIX_FILE
Call Stack \(most recent call first\):
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)$]==]
)

# Test that string and file are mutually exclusive
test_compute_json_matrix_product(
  ARGS
  MATRIX_FILE
  "${CMAKE_CURRENT_SOURCE_DIR}/file_test.json"
  MATRIX_STRING
  [==[{
    "a": [1, 2],
    "b": [3, 4]
  }]==]
  EXPECTED_EXIT_CODE
  1
  EXPECTED_STDERR
  [==[^CMake Error at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Cannot specify both MATRIX_STRING and MATRIX_FILE
Call Stack \(most recent call first\):
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)$]==]
)

# Test that all leaf values are stored properly
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[{
    "a": [1, "str", true, null]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"a": 1},
    {"a": "str"},
    {"a": true},
    {"a": null}
  ]]==])

# Test that keys are sorted
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[{
    "b": [3, 4],
    "a": [1, 2]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"a": 1, "b": 3},
    {"a": 1, "b": 4},
    {"a": 2, "b": 3},
    {"a": 2, "b": 4}
  ]]==])

# Test grouping
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[{
    "_a": [
      {"b": 1, "c": 2},
      {"b": 3, "c": 4}
    ],
    "_d": [
      {"e": 5, "f": 6},
      {"e": 7, "f": 8}
    ]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"b": 1, "c": 2, "e": 5, "f": 6},
    {"b": 1, "c": 2, "e": 7, "f": 8},
    {"b": 3, "c": 4, "e": 5, "f": 6},
    {"b": 3, "c": 4, "e": 7, "f": 8},
  ]]==])

# Test nested lists
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[{
    "a": [[1, 2], [3, 4]]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"a": 1},
    {"a": 2},
    {"a": 3},
    {"a": 4}
  ]]==])

# Test having a list as the root element
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[[
    {"a": 1},
    {"a": 2}
  ]]==]
  EXPECTED_PRODUCT
  [==[[
    {"a": 1},
    {"a": 2}
  ]]==])

# Test having a leaf node as the root element
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[1]==]
  EXPECTED_EXIT_CODE
  1
  EXPECTED_STDERR
  [==[^CMake Error at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Leaf node at root does not have a dictionary as an ancestor\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)$]==]
)

# Test having a list as the root element with no dictionary
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[[1]]==]
  EXPECTED_EXIT_CODE
  1
  EXPECTED_STDERR
  [==[^CMake Error at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Leaf node at root\[0\] does not have a dictionary as an ancestor\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)$]==]
)

# Test having a nested list as the root element with no dictionary
test_compute_json_matrix_product(
  ARGS
  MATRIX_STRING
  [==[[[1]]]==]
  EXPECTED_EXIT_CODE
  1
  EXPECTED_STDERR
  [==[^CMake Error at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Leaf node at root\[0\]\[0\] does not have a dictionary as an ancestor\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)$]==]
)

# Test an improperly named group key
test_compute_json_matrix_product(
  ARGS
  NO_WARN_USED
  MATRIX_STRING
  [==[{
    "a": [
      {
        "b": {"c": 1}
      }
    ]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"c": 1}
  ]]==]
  EXPECTED_STDERR
  [==[^CMake Warning \(dev\) at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Key "b" at root\["a"\]\[0\] is never used in a matrix product entry and is used
  only for grouping\.  Consider renaming it to "_b" to indicate this\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)
This warning is for project developers\.  Use -Wno-dev to suppress it\.

CMake Warning \(dev\) at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Key "a" at root is never used in a matrix product entry and is used only
  for grouping\.  Consider renaming it to "_a" to indicate this\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)
This warning is for project developers\.  Use -Wno-dev to suppress it\.$]==])

# Test an improperly named group key with warning disabled
test_compute_json_matrix_product(
  ARGS
  NO_WARN_UNUSED
  MATRIX_STRING
  [==[{
    "a": [
      {
        "b": {"c": 1}
      }
    ]
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"c": 1}
  ]]==])

# Test an improperly named leaf key
test_compute_json_matrix_product(
  ARGS
  NO_WARN_UNUSED
  MATRIX_STRING
  [==[{
    "_a": [
      {
        "_b": {"_c": 1}
      }
    ],
    "__b": 1
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"__b": 1, "_c": 1},
  ]]==]
  EXPECTED_STDERR
  [==[^CMake Warning \(dev\) at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Key "_c" at root\["_a"\]\[0\]\["_b"\] is used in a matrix product entry even
  though it begins with "_"\.  Consider renaming it to "c" to indicate this\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)
This warning is for project developers\.  Use -Wno-dev to suppress it\.

CMake Warning \(dev\) at [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \(message\):
  Key "__b" at root is used in a matrix product entry even though it begins
  with "__"\.  Consider renaming it to "b" to indicate this\.
Call Stack \(most recent call first\):(
  [^
]*/rapids-cmake/cmake/compute_json_matrix_product\.cmake:[0-9]+ \([a-zA-Z0-9_]+\))+
  [^
]*/testing/cmake/compute_json_matrix_product/test_compute_json_matrix_product\.cmake:[0-9]+ \(rapids_cmake_compute_json_matrix_product\)
This warning is for project developers\.  Use -Wno-dev to suppress it\.$]==])

# Test an improperly named leaf key with warning disabled
test_compute_json_matrix_product(
  ARGS
  NO_WARN_USED
  MATRIX_STRING
  [==[{
    "_a": [
      {
        "_b": {"_c": 1}
      }
    ],
    "__b": 1
  }]==]
  EXPECTED_PRODUCT
  [==[[
    {"__b": 1, "_c": 1},
  ]]==])
