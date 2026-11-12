# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/json/parse.cmake)

# Verify the variable `name` is defined, and that its value is `expected`
function(check_equal name expected)
  if(NOT DEFINED ${name})
    message(FATAL_ERROR "${name}: expected [${expected}] but the variable is not defined")
  endif()
  if(NOT "${${name}}" STREQUAL "${expected}")
    message(FATAL_ERROR "${name}: expected [${expected}] but found [${${name}}]")
  endif()
endfunction()

set(json
    [=[
{
  "name" : "foo",
  "count" : 3,
  "flag" : true,
  "list" : [ "a", "b c", 1 ],
  "empty" : [],
  "obj" : { "x" : 1 },
  "extra" : "ignored"
}
]=])

rapids_json_parse(p STRING "${json}" VALUES name count flag LISTS list empty OBJECTS obj missing)
check_equal(p_name "foo")
check_equal(p_count "3")
check_equal(p_flag "ON")
check_equal(p_list "a;b c;1")
check_equal(p_empty "")

# Declared members that are missing from the document are left unset
if(DEFINED p_missing)
  message(FATAL_ERROR "a missing member should leave its variable unset")
endif()

string(JSON equal EQUAL "${p_obj}" [=[{ "x" : 1 }]=])
if(NOT equal)
  message(FATAL_ERROR "OBJECTS should return the object as JSON, found: ${p_obj}")
endif()

# Verify we unset members from previous call
rapids_json_parse(p STRING [=[{ "count" : 4 }]=] VALUES name count LISTS list)
check_equal(p_count "4")
foreach(key IN ITEMS name list)
  if(DEFINED p_${key})
    message(FATAL_ERROR "p_${key} should not be defined, found [${p_${key}}]")
  endif()
endforeach()

# KEY selects the object to parse
rapids_json_parse(k STRING [=[{ "a" : { "b" : { "v" : "deep" } } }]=] KEY a b VALUES v)
check_equal(k_v "deep")
rapids_json_parse(k STRING [=[[ { "v" : "first" }, { "v" : "second" } ]]=] KEY 1 VALUES v)
check_equal(k_v "second")

# Each record of an array can be parsed by passing it as STRING
set(records [=[{ "r" : [ { "n" : "one", "l" : [ "a" ] }, { "n" : "two" } ] }]=])
string(JSON record_count LENGTH "${records}" r)
set(names)
foreach(index RANGE 0 ${record_count})
  if(index EQUAL record_count)
    break()
  endif()
  string(JSON record GET_RAW "${records}" r ${index})
  rapids_json_parse(rec STRING "${record}" VALUES n LISTS l)
  list(APPEND names "${rec_n}:${rec_l}")
endforeach()
check_equal(names "one:a;two:")

# A `;` in the document and in a value is preserved
set(records [=[{ "r" : [ { "n" : "se;mi" }, { "n" : "two" } ] }]=])
string(JSON record GET_RAW "${records}" r 0)
rapids_json_parse(semi STRING "${record}" VALUES n)
check_equal(semi_n "se;mi")

# Values with characters that are special to CMake are returned untouched
rapids_json_parse(s STRING [=[{ "v" : "a \"quoted\" ${not_a_var} @x@ \\ done" }]=] VALUES v)
check_equal(s_v [=[a "quoted" ${not_a_var} @x@ \ done]=])
