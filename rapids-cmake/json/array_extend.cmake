# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

include("${rapids-cmake-dir}/json/array_append.cmake")

#[=======================================================================[.rst:
rapids_json_array_extend
------------------------

.. versionadded:: v25.08.00

Extend a JSON array with another JSON array.

  .. code-block:: cmake

    rapids_json_array_extend(out_var array values)

``out_var``
  Variable in which to store the result.

``array``
  String containing the JSON array to extend.

``values``
  String containing the JSON array to extend with.

#]=======================================================================]
function(rapids_json_array_extend out_var array values)
  # TODO: Remove this version gate once we require 4.3
  cmake_policy(PUSH)
  cmake_minimum_required(VERSION 4.3)

  string(JSON type TYPE "${array}")
  if(NOT type STREQUAL "ARRAY")
    message(FATAL_ERROR "array argument must be an array")
  endif()
  string(JSON type TYPE "${values}")
  if(NOT type STREQUAL "ARRAY")
    message(FATAL_ERROR "values argument must be an array")
  endif()

  string(JSON len LENGTH "${values}")
  set(it 0)
  while(it LESS len)
    string(JSON value GET_RAW "${values}" "${it}")
    rapids_json_array_append(array "${array}" "${value}")
    math(EXPR it "${it} + 1")
  endwhile()
  set(${out_var} "${array}" PARENT_SCOPE)
  cmake_policy(POP)
endfunction()
