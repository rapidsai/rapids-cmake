# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# Split the array found at `json`/`<member|index>...` into a CMake list with one JSON document per
# element.
#
# On CMake 4.5+ this is a single parse of the array. Older versions index into the array for each
# element. Both return documents that are semantically equal, but are not guaranteed to be
# byte-for-byte identical ( whitespace ).
#
# `_RAPIDS_JSON_FORCE_FALLBACK` is for testing and forces the older implementation.
function(rapids_json_array_split out_var json)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.5 AND NOT _RAPIDS_JSON_FORCE_FALLBACK)
    string(JSON _rapids_items ARRAY_SPLIT "${json}" ${ARGN})
  else()
    string(JSON _rapids_len LENGTH "${json}" ${ARGN})
    set(_rapids_items)
    set(_rapids_it 0)
    while(_rapids_it LESS _rapids_len)
      string(JSON _rapids_item GET_RAW "${json}" ${ARGN} ${_rapids_it})
      # GET_RAW decodes `;`, and a `;` would split the element when it is added to the list. Use the
      # escape sequence to work around these issues
      string(REPLACE ";" "\\u003b" _rapids_item "${_rapids_item}")
      list(APPEND _rapids_items "${_rapids_item}")
      math(EXPR _rapids_it "${_rapids_it} + 1")
    endwhile()
  endif()

  set(${out_var} "${_rapids_items}" PARENT_SCOPE)
endfunction()
