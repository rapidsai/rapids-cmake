# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# rapids-pre-commit-hooks: disable[verify-hardcoded-version]
#[=======================================================================[.rst:
rapids_cmake_target_sources
---------------------------

.. versionadded:: v27.02.00

Add the source files defined in a JSON file to a target.

  .. code-block:: cmake

    rapids_cmake_target_sources(<target> JSON <file>)

Reads the list of source files from the JSON ``<file>`` and adds each one to
``<target>`` as a ``PRIVATE`` source.

``<target>``
  Name of an existing target.

``JSON``
  Path to the JSON file that defines the sources. If relative, it is evaluated
  relative to :cmake:variable:`CMAKE_CURRENT_LIST_DIR <cmake:variable:CMAKE_CURRENT_LIST_DIR>`.

JSON file format
^^^^^^^^^^^^^^^^
  The file must contain a JSON object with a top-level ``srcs`` key whose
  value is an array of strings, each naming a source file:

  .. code-block:: json

    {
      "srcs": [
        "srcs/a.cpp",
        "srcs/b.cu",
        "/absolute/path/c.cpp"
      ]
    }

  - Relative entries are evaluated relative to the directory containing the
    JSON file, not the directory of the calling ``CMakeLists.txt``.
  - Absolute entries are used as is.
  - An empty ``srcs`` array is valid and adds no sources.
  - Keys other than ``srcs`` are ignored.
  - It is an error if the file doesn't exist, isn't valid JSON, doesn't
    contain a ``srcs`` array.

Example on how to properly use :cmake:command:`rapids_cmake_target_sources`:

  .. code-block:: cmake

    add_library(example SHARED)
    rapids_cmake_target_sources(example JSON srcs.json)

This function requires CMake 4.3 or newer.

#]=======================================================================]
# rapids-pre-commit-hooks: enable[verify-hardcoded-version]
function(rapids_cmake_target_sources target)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.target_sources")

  # TODO: Remove this version gate once we require 4.3
  block(SCOPE_FOR POLICIES)
  cmake_minimum_required(VERSION 4.3)

  set(options)
  set(one_value JSON)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT TARGET ${target})
    message(FATAL_ERROR "rapids_cmake_target_sources target '${target}' does not exist")
  endif()
  if(NOT _RAPIDS_JSON)
    message(FATAL_ERROR "rapids_cmake_target_sources requires the JSON argument")
  endif()
  if(_RAPIDS_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "rapids_cmake_target_sources unknown arguments: ${_RAPIDS_UNPARSED_ARGUMENTS}"
    )
  endif()

  # Resolve relative to the caller's directory here, as `CMAKE_CURRENT_LIST_DIR` inside the nested
  # rapids_json_parse call would refer to this file's directory
  cmake_path(ABSOLUTE_PATH _RAPIDS_JSON BASE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" NORMALIZE)

  include("${rapids-cmake-dir}/json/parse.cmake")
  rapids_json_parse(_rapids_json FILE "${_RAPIDS_JSON}" PATHS srcs)
  if(NOT DEFINED _rapids_json_srcs)
    message(FATAL_ERROR "rapids_cmake_target_sources requires 'srcs' to exist in '${_RAPIDS_JSON}'")
  endif()
  if(_rapids_json_srcs)
    target_sources(${target} PRIVATE ${_rapids_json_srcs})
  endif()
  endblock()
endfunction()
