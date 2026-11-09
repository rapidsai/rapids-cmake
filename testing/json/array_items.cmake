# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/array_items.cmake)

function(check_items expected_len items)
  list(LENGTH items actual_len)
  if(NOT actual_len EQUAL expected_len)
    message(FATAL_ERROR "expected ${expected_len} items, found ${actual_len}: ${items}")
  endif()
endfunction()

function(check_json_equal expected actual)
  string(JSON equal EQUAL "${expected}" "${actual}")
  if(NOT equal)
    message(FATAL_ERROR "expected JSON:\n  ${expected}\nactual JSON:\n  ${actual}")
  endif()
endfunction()

set(doc ${CMAKE_CURRENT_BINARY_DIR}/items/doc.json)

# Run every check with the implementation selected by the CMake version, and with the fallback used
# for CMake versions before 4.5
foreach(force_fallback IN ITEMS OFF ON)
  set(_RAPIDS_JSON_FORCE_FALLBACK ${force_fallback})

  # Root array of mixed types
  file(WRITE ${doc} [=[["x y", 1, true, null, { "k" : [1, 2], "s" : "v" }, ["n"]]]=])
  rapids_json_array_items(items FILE ${doc})
  check_items(6 "${items}")
  list(GET items 0 item)
  check_json_equal("\"x y\"" "${item}")
  list(GET items 1 item)
  check_json_equal("1" "${item}")
  list(GET items 2 item)
  check_json_equal("true" "${item}")
  list(GET items 3 item)
  check_json_equal("null" "${item}")
  list(GET items 4 item)
  check_json_equal([=[{ "s" : "v", "k" : [1, 2] }]=] "${item}")
  list(GET items 5 item)
  check_json_equal([=[["n"]]=] "${item}")

  # Empty array
  file(WRITE ${doc} "[]")
  rapids_json_array_items(items FILE ${doc})
  check_items(0 "${items}")

  # Selecting nested arrays by member and index
  file(WRITE ${doc} [=[{ "a" : [ 1, { "b" : [ "c", "d" ] } ] }]=])
  rapids_json_array_items(items FILE ${doc} KEY a 1 b)
  check_items(2 "${items}")
  list(GET items 1 item)
  check_json_equal("\"d\"" "${item}")

  # Records can be parsed again
  file(WRITE ${doc} [=[[{ "n" : "one" }, { "n" : "two" }]]=])
  rapids_json_array_items(items FILE ${doc})
  check_items(2 "${items}")
  list(GET items 1 item)
  string(JSON name GET "${item}" n)
  if(NOT name STREQUAL "two")
    message(FATAL_ERROR "record 1 should be `two`, found ${name}")
  endif()

  # The file is tracked
  get_property(depends DIRECTORY PROPERTY CMAKE_CONFIGURE_DEPENDS)
  if(NOT "${doc}" IN_LIST depends)
    message(FATAL_ERROR "JSON file was not added to CMAKE_CONFIGURE_DEPENDS: ${depends}")
  endif()

  # The directory of the file is only reported when asked for, in the requested variable
  unset(items_dir)
  rapids_json_array_items(items FILE ${doc})
  if(DEFINED items_dir OR DEFINED items_BASE_DIR)
    message(FATAL_ERROR "no variable should be set without BASE_DIR_VARIABLE")
  endif()
  rapids_json_array_items(items FILE ${doc} BASE_DIR_VARIABLE items_dir)
  if(NOT items_dir STREQUAL "${CMAKE_CURRENT_BINARY_DIR}/items")
    message(FATAL_ERROR "unexpected BASE_DIR_VARIABLE value: ${items_dir}")
  endif()
endforeach()
