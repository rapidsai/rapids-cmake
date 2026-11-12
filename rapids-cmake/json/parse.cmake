# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_json_parse
-----------------

.. versionadded:: v27.02.00

Extract the members of a JSON object into CMake variables.

  .. code-block:: cmake

    rapids_json_parse(<prefix>
                      (FILE <file> | STRING <json>)
                      [KEY <member|index>...]
                      [BASE_DIR <dir>]
                      [VALUES <key>...]
                      [LISTS <key>...]
                      [PATHS <key>...]
                      [OBJECTS <key>...]
    )

Reads a JSON object and stores the members that the caller has asked for in
variables named ``<prefix>_<key>``. The layout of the JSON document is
described by the keywords given to the call, in the same way
:cmake:command:`cmake_parse_arguments <cmake:command:cmake_parse_arguments>`
describes the layout of command line arguments. The members of each record of
an array can be parsed by giving the record to this function as ``STRING``,
after extracting it with :cmake:command:`string(JSON ... GET_RAW) <cmake:command:string>`.

``<prefix>``
  Prefix of the variables that are set in the calling scope. All variables
  that could be set by this call are unset first, so it is safe to re-use a ``<prefix>``
  for multiple invocations.

``FILE``
  Path to the JSON file to read. If relative, it is evaluated relative to
  :cmake:variable:`CMAKE_CURRENT_LIST_DIR <cmake:variable:CMAKE_CURRENT_LIST_DIR>`.
  The file is added to the ``CMAKE_CONFIGURE_DEPENDS`` directory property so
  that editing it re-runs the CMake configuration. Mutually exclusive with
  ``STRING``.

``STRING``
  String containing the JSON document to read. Mutually exclusive with ``FILE``.

``KEY``
  Sequence of object members and array indices, in the same form as accepted
  by :cmake:command:`string(JSON) <cmake:command:string>`, that locates the
  object to parse. When not provided the document itself is parsed.

``BASE_DIR``
  An absolute path of the directory that relative entries of ``PATHS`` are
  evaluated relative to.

``VALUES``
  Members that hold a single value. The value is stored as is.

``LISTS``
  Members that hold an array. The array is stored as a CMake list with an
  entry for each element of the array.

``PATHS``
  Members that hold a path, or an array of paths. A member that is neither a
  string nor an array is an error. The result is always a CMake list of
  absolute paths, which has a single entry when the member is a string.
  Absolute paths are used as is, and relative paths are made absolute by:

  * ``BASE_DIR`` when provided.
  * When ``FILE`` is used, the directory containing the JSON file.
  * When ``STRING`` is used, the
    :cmake:variable:`CMAKE_CURRENT_LIST_DIR <cmake:variable:CMAKE_CURRENT_LIST_DIR>`
    of the caller.

  Paths are not normalized, so entries such as ``../a.cpp`` keep their ``..``
  component.

``OBJECTS``
  Members that hold an object. The object is stored as a JSON string that can
  be given to another call of ``rapids_json_parse`` as the ``STRING``
  argument.

A member can be declared by a single keyword only. Members that exist in the
JSON object, but are not declared, are ignored. All declared members are
optional, callers that need a member should check that its variable is
defined.

Example on how to properly use :cmake:command:`rapids_json_parse`:

  .. code-block:: cmake

    # kernel.json:
    # {
    #   "name": "scan_@type@",
    #   "input": "scan.cu.in",
    #   "headers": [ "<common.hpp>", "<scan.hpp>" ],
    #   "output_dir": "generated"
    # }
    rapids_json_parse(_kernel FILE kernel.json
                      VALUES name output_dir
                      PATHS input
                      LISTS headers
    )
    message(STATUS "input is ${_kernel_input}")
    message(STATUS "headers are ${_kernel_headers}")

Result Variables
^^^^^^^^^^^^^^^^
  ``<prefix>_<key>``
    Set for each declared member that exists in the JSON object. Members that
    don't exist leave the variable unset.

Limitations
^^^^^^^^^^^
  A ``;`` is supported in the ``STRING`` document and in ``VALUES`` and ``OBJECTS``
  members. It is not supported in the elements of ``LISTS`` and ``PATHS`` members, since
  they are returned as CMake lists.

  This function requires CMake 4.3 or newer.

#]=======================================================================]
# rapids-pre-commit-hooks: enable[verify-hardcoded-version]

# cmake-lint: disable=C0103,R0912,R0915
function(rapids_json_parse _rapids_prefix)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.json.parse")

  # TODO: Remove this version gate once we require 4.3
  block(SCOPE_FOR POLICIES)
  cmake_minimum_required(VERSION 4.3)

  set(_rapids_kinds VALUES LISTS PATHS OBJECTS)

  set(options)
  set(one_value FILE STRING BASE_DIR)
  set(multi_value KEY ${_rapids_kinds})
  # PARSE_ARGV keeps a `;` in the JSON `STRING` intact, ARGN would split it
  cmake_parse_arguments(PARSE_ARGV 1 _RAPIDS "${options}" "${one_value}" "${multi_value}")

  # Collect the declared keys, and make sure each is declared once
  set(_rapids_declared ${_RAPIDS_VALUES} ${_RAPIDS_LISTS} ${_RAPIDS_PATHS} ${_RAPIDS_OBJECTS})
  set(_rapids_unique ${_rapids_declared})
  list(REMOVE_DUPLICATES _rapids_unique)
  list(LENGTH _rapids_declared _rapids_declared_len)
  list(LENGTH _rapids_unique _rapids_unique_len)
  if(NOT _rapids_declared_len EQUAL _rapids_unique_len)
    message(FATAL_ERROR "rapids_json_parse keys can only be declared once: ${_rapids_declared}")
  endif()

  # Nothing from a previous call with the same prefix can be left behind
  foreach(_rapids_key IN LISTS _rapids_declared)
    unset(${_rapids_prefix}_${_rapids_key} PARENT_SCOPE)
  endforeach()

  include("${rapids-cmake-dir}/json/detail/load_document.cmake")
  if(_RAPIDS_FILE AND _RAPIDS_STRING)
    message(FATAL_ERROR "rapids_json_parse can't be given both FILE and STRING")
  elseif(_RAPIDS_FILE)
    rapids_json_load_document("rapids_json_parse" "${CMAKE_CURRENT_LIST_DIR}" FILE
                              "${_RAPIDS_FILE}" JSON_VARIABLE _rapids_json DIR_VARIABLE
                              _rapids_base)
  elseif(_RAPIDS_STRING)
    rapids_json_load_document("rapids_json_parse" "${CMAKE_CURRENT_LIST_DIR}" STRING
                              "${_RAPIDS_STRING}" JSON_VARIABLE _rapids_json DIR_VARIABLE
                              _rapids_base)
  else()
    message(FATAL_ERROR "rapids_json_parse requires one of FILE or STRING")
  endif()

  # Get the payload for the key
  if(_RAPIDS_KEY)
    string(JSON _rapids_json ERROR_VARIABLE _rapids_error GET "${_rapids_json}" ${_RAPIDS_KEY})
    if(_rapids_error)
      message(FATAL_ERROR "rapids_json_parse could not find KEY '${_RAPIDS_KEY}'")
    endif()
  endif()
  string(JSON _rapids_type ERROR_VARIABLE _rapids_error TYPE "${_rapids_json}")
  if(_rapids_error OR NOT _rapids_type STREQUAL "OBJECT")
    message(FATAL_ERROR "rapids_json_parse requires the JSON element to be an object")
  endif()

  if(DEFINED _RAPIDS_BASE_DIR)
    cmake_path(IS_ABSOLUTE _RAPIDS_BASE_DIR _rapids_base_is_abs)
    if(NOT _rapids_base_is_abs)
      message(FATAL_ERROR "rapids_json_parse BASE_DIR '${_RAPIDS_BASE_DIR}' must be an absolute path"
      )
    endif()
    set(_rapids_base "${_RAPIDS_BASE_DIR}")
  endif()

  foreach(_rapids_kind IN LISTS _rapids_kinds)
    foreach(_rapids_key IN LISTS _RAPIDS_${_rapids_kind})
      string(JSON _rapids_type ERROR_VARIABLE _rapids_error TYPE "${_rapids_json}" "${_rapids_key}")
      if(_rapids_error)
        continue()
      endif()

      if(_rapids_kind STREQUAL "VALUES")
        string(JSON _rapids_result GET "${_rapids_json}" "${_rapids_key}")

      elseif(_rapids_kind STREQUAL "LISTS")
        if(NOT _rapids_type STREQUAL "ARRAY")
          message(FATAL_ERROR "rapids_json_parse requires '${_rapids_key}' to be an array")
        endif()
        include("${rapids-cmake-dir}/json/detail/array_split.cmake")
        rapids_json_array_split(_rapids_items "${_rapids_json}" "${_rapids_key}")
        set(_rapids_result)
        foreach(_rapids_item IN LISTS _rapids_items)
          string(JSON _rapids_value GET "${_rapids_item}")
          list(APPEND _rapids_result "${_rapids_value}")
        endforeach()

      elseif(_rapids_kind STREQUAL "PATHS")
        # A string is a list with a single path
        set(_rapids_result)
        if(_rapids_type STREQUAL "STRING")
          string(JSON _rapids_result GET "${_rapids_json}" "${_rapids_key}")
        elseif(_rapids_type STREQUAL "ARRAY")
          include("${rapids-cmake-dir}/json/detail/array_split.cmake")
          rapids_json_array_split(_rapids_items "${_rapids_json}" "${_rapids_key}")
          foreach(_rapids_item IN LISTS _rapids_items)
            string(JSON _rapids_value GET "${_rapids_item}")
            list(APPEND _rapids_result "${_rapids_value}")
          endforeach()
        else()
          message(FATAL_ERROR "rapids_json_parse requires '${_rapids_key}' to be a string or an array"
          )
        endif()

        list(TRANSFORM _rapids_result PREPEND "${_rapids_base}/" REGEX "^[^/]")

      elseif(_rapids_kind STREQUAL "OBJECTS")
        if(NOT _rapids_type STREQUAL "OBJECT")
          message(FATAL_ERROR "rapids_json_parse requires '${_rapids_key}' to be an object")
        endif()
        string(JSON _rapids_result GET "${_rapids_json}" "${_rapids_key}")
      endif()

      set(${_rapids_prefix}_${_rapids_key} "${_rapids_result}" PARENT_SCOPE)
    endforeach()
  endforeach()
  endblock()
endfunction()
