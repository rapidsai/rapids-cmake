# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_json_array_items
-----------------------

.. versionadded:: v27.02.00

Split a JSON array into a list with one JSON document per element.

  .. code-block:: cmake

    rapids_json_array_items(<out_var>
                            FILE <file>
                            [KEY <member|index>...]
                            [BASE_DIR_VARIABLE <variable>]
    )


Store each JSON element in the output variable.

An entry can be given to :cmake:command:`rapids_json_parse` as its ``STRING``
argument, which makes it possible to process a collection of records that are
all described by a single JSON file.

``<out_var>``
  Name of the variable in which to store the list of elements. An empty array
  results in an empty list.

``FILE``
  Path to the JSON file to read. If relative, it is evaluated relative to
  :cmake:variable:`CMAKE_CURRENT_LIST_DIR <cmake:variable:CMAKE_CURRENT_LIST_DIR>`.
  The file is added to the ``CMAKE_CONFIGURE_DEPENDS`` directory property.

``KEY``
  Sequence of object members and array indices, in the same form as accepted
  by :cmake:command:`string(JSON) <cmake:command:string>`, that locates the
  array to split. When not provided the document itself is assumed to be an array.

``BASE_DIR_VARIABLE``
  Name of the variable in which to store the absolute path of the directory
  containing the JSON file. It is the directory that
  :cmake:command:`rapids_json_parse` should be given as ``BASE_DIR`` for
  relative paths of the records to be evaluated relative to the file.

Example on how to properly use :cmake:command:`rapids_json_array_items`:

  .. code-block:: cmake

    # kernels.json: { "kernels": [ { "name": "a" }, { "name": "b" } ] }
    rapids_json_array_items(kernels FILE kernels.json KEY kernels
                            BASE_DIR_VARIABLE kernels_dir)
    foreach(kernel IN LISTS kernels)
      rapids_json_parse(_kernel STRING "${kernel}" BASE_DIR "${kernels_dir}" VALUES name)
      message(STATUS "kernel: ${_kernel_name}")
    endforeach()

Result Variables
^^^^^^^^^^^^^^^^
  ``<out_var>``
    The list of elements. Each element is semantically equal to the element
    in the document, but whitespace is not preserved.

Limitations
^^^^^^^^^^^
  The result is a CMake list, which can't represent a ``;`` inside of an
  element. JSON strings that contain a ``;`` are not supported.

  This function requires CMake 4.3 or newer. CMake 4.5 or newer is faster
  for large arrays as it parses the array a single time.

#]=======================================================================]
# rapids-pre-commit-hooks: enable[verify-hardcoded-version]
function(rapids_json_array_items out_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.json.array_items")

  # TODO: Remove this version gate once we require 4.3
  block(SCOPE_FOR POLICIES)
  cmake_minimum_required(VERSION 4.3)

  set(options)
  set(one_value FILE BASE_DIR_VARIABLE)
  set(multi_value KEY)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT _RAPIDS_FILE)
    message(FATAL_ERROR "rapids_json_array_items requires the FILE argument")
  endif()
  if(_RAPIDS_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "rapids_json_array_items unknown arguments: ${_RAPIDS_UNPARSED_ARGUMENTS}")
  endif()

  include("${rapids-cmake-dir}/json/detail/load_document.cmake")
  rapids_json_load_document("rapids_json_array_items" "${CMAKE_CURRENT_LIST_DIR}" FILE
                            "${_RAPIDS_FILE}" JSON_VARIABLE _rapids_json DIR_VARIABLE _rapids_dir)

  string(JSON _rapids_type ERROR_VARIABLE _rapids_error TYPE "${_rapids_json}" ${_RAPIDS_KEY})
  if(_rapids_error OR NOT _rapids_type STREQUAL "ARRAY")
    message(FATAL_ERROR "rapids_json_array_items requires the selected JSON element to be an array")
  endif()

  include("${rapids-cmake-dir}/json/detail/array_split.cmake")
  rapids_json_array_split(_rapids_items "${_rapids_json}" ${_RAPIDS_KEY})

  set(${out_var} "${_rapids_items}" PARENT_SCOPE)
  if(_RAPIDS_BASE_DIR_VARIABLE)
    set(${_RAPIDS_BASE_DIR_VARIABLE} "${_rapids_dir}" PARENT_SCOPE)
  endif()
  endblock()
endfunction()
