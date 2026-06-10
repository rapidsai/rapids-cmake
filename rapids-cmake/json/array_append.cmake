# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_json_array_append
------------------------

.. versionadded:: v25.08.00

Append an element to a JSON array.

  .. code-block:: cmake

    rapids_json_array_append(out_var array value)

``out_var``
  Variable in which to store the result.

``array``
  String containing the JSON array to append to.

``value``
  String containing the JSON value to append.

#]=======================================================================]
function(rapids_json_array_append out_var array value)
  string(JSON type TYPE "${array}")
  if(NOT type STREQUAL "ARRAY")
    message(FATAL_ERROR "array argument must be an array")
  endif()

  string(JSON len LENGTH "${array}")
  string(JSON array SET "${array}" "${len}" "${value}")
  set(${out_var} "${array}" PARENT_SCOPE)
endfunction()
