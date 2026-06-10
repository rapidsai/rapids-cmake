# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

include("${rapids-cmake-dir}/json/array_append.cmake")
include("${rapids-cmake-dir}/json/array_extend.cmake")

# Product a JSON object with a queue entry
function(_rapids_json_cmp_queue_item out_var path key matrix)
  string(JSON item SET "{}" path "${path}")
  string(JSON item SET "${item}" key "${key}")
  string(JSON item SET "${item}" matrix "${matrix}")
  set(${out_var} "${item}" PARENT_SCOPE)
endfunction()

# Produce a JSON object with a matrix entry, telling whether or not the most direct ancestor key was
# used in the entry
function(_rapids_json_cmp_generator_item out_var entry used)
  string(JSON item SET "{}" entry "${entry}")
  if(used)
    string(JSON item SET "${item}" used true)
  else()
    string(JSON item SET "${item}" used false)
  endif()
  set(${out_var} "${item}" PARENT_SCOPE)
endfunction()

# Turn a JSON array of strings and numbers into a path representation
function(_rapids_json_cmp_path_repr out_var path)
  string(JSON len LENGTH "${path}")
  set(path_repr "")
  set(it 0)
  while(it LESS len)
    string(JSON path_component GET_RAW "${path}" "${it}")
    string(APPEND path_repr "[${path_component}]")
    math(EXPR it "${it} + 1")
  endwhile()
  set(${out_var} "${path_repr}" PARENT_SCOPE)
endfunction()

# Iterate the next queued dimension
function(_rapids_json_cmp_iterate_next_dimension out_var)
  set(options)
  set(one_value QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  string(JSON queue_len LENGTH "${_RAPIDS_QUEUE}")
  if(queue_len EQUAL 0)
    _rapids_json_cmp_generator_item(item "${_RAPIDS_ENTRY}" false)
    set(${out_var} "[${item}]" PARENT_SCOPE)
    return()
  endif()

  string(JSON path GET_RAW "${_RAPIDS_QUEUE}" 0 path)
  string(JSON key GET_RAW "${_RAPIDS_QUEUE}" 0 key)
  string(JSON matrix GET_RAW "${_RAPIDS_QUEUE}" 0 matrix)
  string(JSON tail REMOVE "${_RAPIDS_QUEUE}" 0)

  set(used FALSE)
  set(result "[]")
  _rapids_json_cmp_impl(impl_result PATH "${path}" KEY "${key}" MATRIX "${matrix}" QUEUE "${tail}"
                        ENTRY "${_RAPIDS_ENTRY}" WARN_USED "${_RAPIDS_WARN_USED}" WARN_UNUSED
                        "${_RAPIDS_WARN_UNUSED}")

  string(JSON impl_len LENGTH "${impl_result}")
  set(it 0)
  while(it LESS impl_len)
    string(JSON entry GET_RAW "${impl_result}" "${it}")
    string(JSON u GET "${entry}" used)
    if(u)
      set(used TRUE)
    endif()
    rapids_json_array_append(result "${result}" "${entry}")
    math(EXPR it "${it} + 1")
  endwhile()

  string(JSON path_len LENGTH "${path}")
  if(path_len GREATER 0)
    math(EXPR last_index "${path_len} - 1")
    string(JSON last_type TYPE "${path}" "${last_index}")
    if(last_type STREQUAL "STRING")
      string(JSON last GET "${path}" "${last_index}")
      string(REGEX MATCH "^_*" underscores "${last}")
      string(REGEX REPLACE "^_*" "" rest "${last}")

      string(JSON path_head REMOVE "${path}" "${last_index}")
      _rapids_json_cmp_path_repr(path_repr "${path_head}")

      string(JSON last_json STRING_ENCODE "${last}")
      string(JSON underscores_json STRING_ENCODE "${underscores}")
      string(JSON rest_json STRING_ENCODE "${rest}")
      string(JSON hidden_json STRING_ENCODE "_${last}")

      if(_RAPIDS_WARN_USED AND used AND underscores)
        message(AUTHOR_WARNING "Key ${last_json} at root${path_repr} is used in a matrix product entry even though it begins with ${underscores_json}. Consider renaming it to ${rest_json} to indicate this."
        )
      elseif(_RAPIDS_WARN_UNUSED AND NOT used AND NOT underscores)
        message(AUTHOR_WARNING "Key ${last_json} at root${path_repr} is never used in a matrix product entry and is used only for grouping. Consider renaming it to ${hidden_json} to indicate this."
        )
      endif()
    endif()
  endif()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# Handle object nodes
function(_rapids_json_cmp_dict out_var)
  set(options)
  set(one_value PATH MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(keys)
  string(JSON len LENGTH "${_RAPIDS_MATRIX}")
  set(it 0)
  while(it LESS len)
    string(JSON member MEMBER "${_RAPIDS_MATRIX}" "${it}")
    list(APPEND keys "${member}")
    math(EXPR it "${it} + 1")
  endwhile()
  list(SORT keys)

  set(next_queue "[]")
  foreach(member IN LISTS keys)
    string(JSON member_json STRING_ENCODE "${member}")
    rapids_json_array_append(child_path "${_RAPIDS_PATH}" "${member_json}")
    string(JSON child_matrix GET_RAW "${_RAPIDS_MATRIX}" "${member}")
    _rapids_json_cmp_queue_item(item "${child_path}" "${member_json}" "${child_matrix}")
    rapids_json_array_append(next_queue "${next_queue}" "${item}")
  endforeach()
  rapids_json_array_extend(next_queue "${next_queue}" "${_RAPIDS_QUEUE}")

  _rapids_json_cmp_iterate_next_dimension(
    nested_result QUEUE "${next_queue}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED "${_RAPIDS_WARN_USED}"
    WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")

  set(result "[]")
  string(JSON nested_len LENGTH "${nested_result}")
  set(it 0)
  while(it LESS nested_len)
    string(JSON nested_entry GET_RAW "${nested_result}" "${it}" entry)
    _rapids_json_cmp_generator_item(item "${nested_entry}" false)
    rapids_json_array_append(result "${result}" "${item}")
    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# Handle array nodes
function(_rapids_json_cmp_array out_var)
  set(options)
  set(one_value PATH KEY MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(result "[]")
  string(JSON len LENGTH "${_RAPIDS_MATRIX}")
  set(it 0)
  while(it LESS len)
    rapids_json_array_append(child_path "${_RAPIDS_PATH}" "${it}")
    string(JSON child_matrix GET_RAW "${_RAPIDS_MATRIX}" "${it}")
    _rapids_json_cmp_queue_item(item "${child_path}" "${_RAPIDS_KEY}" "${child_matrix}")

    set(next_queue "[]")
    rapids_json_array_append(next_queue "${next_queue}" "${item}")
    rapids_json_array_extend(next_queue "${next_queue}" "${_RAPIDS_QUEUE}")

    _rapids_json_cmp_iterate_next_dimension(
      nested_result QUEUE "${next_queue}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED "${_RAPIDS_WARN_USED}"
      WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
    string(JSON nested_len LENGTH "${nested_result}")
    set(it2 0)
    while(it2 LESS nested_len)
      string(JSON nested_item GET_RAW "${nested_result}" "${it2}")
      rapids_json_array_append(result "${result}" "${nested_item}")
      math(EXPR it2 "${it2} + 1")
    endwhile()

    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# Handle leaf nodes
function(_rapids_json_cmp_leaf out_var)
  set(options)
  set(one_value PATH KEY MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  string(JSON key_type TYPE "${_RAPIDS_KEY}")
  if(key_type STREQUAL "NULL")
    _rapids_json_cmp_path_repr(path_repr "${_RAPIDS_PATH}")
    message(FATAL_ERROR "Leaf node at root${path_repr} does not have a dictionary as an ancestor.")
  endif()

  string(JSON key_value GET "${_RAPIDS_KEY}")
  string(JSON entry SET "${_RAPIDS_ENTRY}" "${key_value}" "${_RAPIDS_MATRIX}")
  _rapids_json_cmp_iterate_next_dimension(
    nested_result QUEUE "${_RAPIDS_QUEUE}" ENTRY "${entry}" WARN_USED "${_RAPIDS_WARN_USED}"
    WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")

  set(result "[]")
  string(JSON nested_len LENGTH "${nested_result}")
  set(it 0)
  while(it LESS nested_len)
    string(JSON nested_entry GET_RAW "${nested_result}" "${it}" entry)
    _rapids_json_cmp_generator_item(item "${nested_entry}" true)
    rapids_json_array_append(result "${result}" "${item}")
    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# Internal implementation of rapids_json_compute_matrix_product()
function(_rapids_json_cmp_impl out_var)
  set(options)
  set(one_value PATH KEY MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  string(JSON matrix_type TYPE "${_RAPIDS_MATRIX}")

  if(matrix_type STREQUAL "OBJECT")
    _rapids_json_cmp_dict(result PATH "${_RAPIDS_PATH}" MATRIX "${_RAPIDS_MATRIX}" QUEUE
                          "${_RAPIDS_QUEUE}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED
                          "${_RAPIDS_WARN_USED}" WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
  elseif(matrix_type STREQUAL "ARRAY")
    _rapids_json_cmp_array(result PATH "${_RAPIDS_PATH}" KEY "${_RAPIDS_KEY}" MATRIX
                           "${_RAPIDS_MATRIX}" QUEUE "${_RAPIDS_QUEUE}" ENTRY "${_RAPIDS_ENTRY}"
                           WARN_USED "${_RAPIDS_WARN_USED}" WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
  else()
    _rapids_json_cmp_leaf(result PATH "${_RAPIDS_PATH}" KEY "${_RAPIDS_KEY}" MATRIX
                          "${_RAPIDS_MATRIX}" QUEUE "${_RAPIDS_QUEUE}" ENTRY "${_RAPIDS_ENTRY}"
                          WARN_USED "${_RAPIDS_WARN_USED}" WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
  endif()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()
