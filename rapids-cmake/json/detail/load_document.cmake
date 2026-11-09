# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# rapids_json_load_document(<command> <caller_dir> (FILE <file> | STRING <json>) JSON_VARIABLE
# <variable> DIR_VARIABLE <variable>)
#
# Load a JSON document from `FILE` or `STRING` into `JSON_VARIABLE`, and the directory relative
# paths should be evaluated against into `DIR_VARIABLE`. Exactly one of `FILE` or `STRING` must be
# provided, which is checked by the public functions.
#
# `command` is the name of the public function, which is used in error messages.
#
# `caller_dir` is the directory that relative `FILE` paths are evaluated against, and is the
# directory reported for `STRING` documents. It must be provided by the public function since
# `CMAKE_CURRENT_LIST_DIR` here would be the directory of this file.
function(rapids_json_load_document command caller_dir)
  set(options)
  set(one_value FILE STRING JSON_VARIABLE DIR_VARIABLE)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(DEFINED _RAPIDS_FILE)
    cmake_path(ABSOLUTE_PATH _RAPIDS_FILE BASE_DIRECTORY "${caller_dir}" NORMALIZE OUTPUT_VARIABLE
               _rapids_json_file)
    if(NOT EXISTS "${_rapids_json_file}")
      message(FATAL_ERROR "${command} JSON file '${_rapids_json_file}' does not exist")
    endif()
    # Editing the file needs to re-run configure
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_rapids_json_file}")
    file(READ "${_rapids_json_file}" _rapids_json_content)
    cmake_path(GET _rapids_json_file PARENT_PATH _rapids_json_dir)
    set(_rapids_json_origin "file '${_rapids_json_file}'")
  else()
    set(_rapids_json_content "${_RAPIDS_STRING}")
    set(_rapids_json_dir "${caller_dir}")
    set(_rapids_json_origin "string")
  endif()

  string(JSON _rapids_json_type ERROR_VARIABLE _rapids_json_error TYPE "${_rapids_json_content}")
  if(_rapids_json_error)
    message(FATAL_ERROR "${command} JSON ${_rapids_json_origin} is not valid JSON: ${_rapids_json_error}"
    )
  endif()

  set(${_RAPIDS_JSON_VARIABLE} "${_rapids_json_content}" PARENT_SCOPE)
  set(${_RAPIDS_DIR_VARIABLE} "${_rapids_json_dir}" PARENT_SCOPE)
endfunction()
