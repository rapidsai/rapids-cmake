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

set(doc_dir ${CMAKE_CURRENT_BINARY_DIR}/paths/docs)
file(WRITE ${doc_dir}/paths.json
     [=[
{
  "path" : "rel/a.cpp",
  "abs" : "/abs/b.cpp",
  "paths" : [ "c.cpp", "/abs/d.cpp", "sub/e.cpp" ],
  "none" : []
}
]=])

# Validate entries are evaluated relative to the JSON file
rapids_json_parse(p FILE ${doc_dir}/paths.json PATHS path abs paths none)
check_equal(p_path "${doc_dir}/rel/a.cpp")
check_equal(p_abs "/abs/b.cpp")
check_equal(p_paths "${doc_dir}/c.cpp;/abs/d.cpp;${doc_dir}/sub/e.cpp")
check_equal(p_none "")

# Validate BASE_DIR works as expected
rapids_json_parse(p FILE ${doc_dir}/paths.json BASE_DIR /some/where PATHS path abs paths none)
check_equal(p_path "/some/where/rel/a.cpp")
check_equal(p_abs "/abs/b.cpp")
check_equal(p_paths "/some/where/c.cpp;/abs/d.cpp;/some/where/sub/e.cpp")
check_equal(p_none "")

# Validate relative FILE
cmake_path(RELATIVE_PATH doc_dir BASE_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" OUTPUT_VARIABLE rel_dir)
rapids_json_parse(p FILE ${rel_dir}/paths.json PATHS path)
check_equal(p_path "${doc_dir}/rel/a.cpp")

# Validate relative STRING documents are evaluated relative to the calling list file by default
rapids_json_parse(p STRING [=[{ "path" : "x.cpp" }]=] PATHS path)
check_equal(p_path "${CMAKE_CURRENT_LIST_DIR}/x.cpp")
