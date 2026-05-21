# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# TODO: Remove this version gate once we require 4.3
cmake_minimum_required(VERSION 4.3)

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_array_append out_var array value)
  string(JSON len LENGTH "${array}")
  string(JSON array SET "${array}" "${len}" "${value}")
  set(${out_var} "${array}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_array_extend out_var array values)
  string(JSON len LENGTH "${values}")
  set(it 0)
  while(it LESS len)
    string(JSON value GET_RAW "${values}" "${it}")
    _rapids_cmake_cjmp_array_append(array "${array}" "${value}")
    math(EXPR it "${it} + 1")
  endwhile()
  set(${out_var} "${array}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_queue_item out_var path key matrix)
  string(JSON item SET "{}" path "${path}")
  string(JSON item SET "${item}" key "${key}")
  string(JSON item SET "${item}" matrix "${matrix}")
  set(${out_var} "${item}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_generator_item out_var entry used)
  string(JSON item SET "{}" entry "${entry}")
  if(used)
    string(JSON item SET "${item}" used true)
  else()
    string(JSON item SET "${item}" used false)
  endif()
  set(${out_var} "${item}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_path_repr out_var path)
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

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_iterate_next_dimension out_var)
  set(options)
  set(one_value QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  string(JSON queue_len LENGTH "${_RAPIDS_QUEUE}")
  if(queue_len EQUAL 0)
    _rapids_cmake_cjmp_generator_item(item "${_RAPIDS_ENTRY}" false)
    set(${out_var} "[${item}]" PARENT_SCOPE)
    return()
  endif()

  string(JSON path GET_RAW "${_RAPIDS_QUEUE}" 0 path)
  string(JSON key GET_RAW "${_RAPIDS_QUEUE}" 0 key)
  string(JSON matrix GET_RAW "${_RAPIDS_QUEUE}" 0 matrix)
  string(JSON tail REMOVE "${_RAPIDS_QUEUE}" 0)

  set(used FALSE)
  set(result "[]")
  _rapids_cmake_cjmp_impl(impl_result PATH "${path}" KEY "${key}" MATRIX "${matrix}" QUEUE
                          "${tail}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED "${_RAPIDS_WARN_USED}"
                          WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")

  string(JSON impl_len LENGTH "${impl_result}")
  set(it 0)
  while(it LESS impl_len)
    string(JSON entry GET_RAW "${impl_result}" "${it}")
    string(JSON u GET "${entry}" used)
    if(u)
      set(used TRUE)
    endif()
    _rapids_cmake_cjmp_array_append(result "${result}" "${entry}")
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
      _rapids_cmake_cjmp_path_repr(path_repr "${path_head}")

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

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_dict out_var)
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
    _rapids_cmake_cjmp_array_append(child_path "${_RAPIDS_PATH}" "${member_json}")
    string(JSON child_matrix GET_RAW "${_RAPIDS_MATRIX}" "${member}")
    _rapids_cmake_cjmp_queue_item(item "${child_path}" "${member_json}" "${child_matrix}")
    _rapids_cmake_cjmp_array_append(next_queue "${next_queue}" "${item}")
  endforeach()
  _rapids_cmake_cjmp_array_extend(next_queue "${next_queue}" "${_RAPIDS_QUEUE}")

  _rapids_cmake_cjmp_iterate_next_dimension(
    nested_result QUEUE "${next_queue}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED "${_RAPIDS_WARN_USED}"
    WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")

  set(result "[]")
  string(JSON nested_len LENGTH "${nested_result}")
  set(it 0)
  while(it LESS nested_len)
    string(JSON nested_entry GET_RAW "${nested_result}" "${it}" entry)
    _rapids_cmake_cjmp_generator_item(item "${nested_entry}" false)
    _rapids_cmake_cjmp_array_append(result "${result}" "${item}")
    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_array out_var)
  set(options)
  set(one_value PATH KEY MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(result "[]")
  string(JSON len LENGTH "${_RAPIDS_MATRIX}")
  set(it 0)
  while(it LESS len)
    _rapids_cmake_cjmp_array_append(child_path "${_RAPIDS_PATH}" "${it}")
    string(JSON child_matrix GET_RAW "${_RAPIDS_MATRIX}" "${it}")
    _rapids_cmake_cjmp_queue_item(item "${child_path}" "${_RAPIDS_KEY}" "${child_matrix}")

    set(next_queue "[]")
    _rapids_cmake_cjmp_array_append(next_queue "${next_queue}" "${item}")
    _rapids_cmake_cjmp_array_extend(next_queue "${next_queue}" "${_RAPIDS_QUEUE}")

    _rapids_cmake_cjmp_iterate_next_dimension(
      nested_result QUEUE "${next_queue}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED "${_RAPIDS_WARN_USED}"
      WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
    string(JSON nested_len LENGTH "${nested_result}")
    set(it2 0)
    while(it2 LESS nested_len)
      string(JSON nested_item GET_RAW "${nested_result}" "${it2}")
      _rapids_cmake_cjmp_array_append(result "${result}" "${nested_item}")
      math(EXPR it2 "${it2} + 1")
    endwhile()

    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_leaf out_var)
  set(options)
  set(one_value PATH KEY MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  string(JSON key_type TYPE "${_RAPIDS_KEY}")
  if(key_type STREQUAL "NULL")
    _rapids_cmake_cjmp_path_repr(path_repr "${_RAPIDS_PATH}")
    message(FATAL_ERROR "Leaf node at root${path_repr} does not have a dictionary as an ancestor.")
  endif()

  string(JSON key_value GET "${_RAPIDS_KEY}")
  string(JSON entry SET "${_RAPIDS_ENTRY}" "${key_value}" "${_RAPIDS_MATRIX}")
  _rapids_cmake_cjmp_iterate_next_dimension(
    nested_result QUEUE "${_RAPIDS_QUEUE}" ENTRY "${entry}" WARN_USED "${_RAPIDS_WARN_USED}"
    WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")

  set(result "[]")
  string(JSON nested_len LENGTH "${nested_result}")
  set(it 0)
  while(it LESS nested_len)
    string(JSON nested_entry GET_RAW "${nested_result}" "${it}" entry)
    _rapids_cmake_cjmp_generator_item(item "${nested_entry}" true)
    _rapids_cmake_cjmp_array_append(result "${result}" "${item}")
    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

# rapids-lint: disable=C0111
function(_rapids_cmake_cjmp_impl out_var)
  set(options)
  set(one_value PATH KEY MATRIX QUEUE ENTRY WARN_USED WARN_UNUSED)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  string(JSON matrix_type TYPE "${_RAPIDS_MATRIX}")

  if(matrix_type STREQUAL "OBJECT")
    _rapids_cmake_cjmp_dict(result PATH "${_RAPIDS_PATH}" MATRIX "${_RAPIDS_MATRIX}" QUEUE
                            "${_RAPIDS_QUEUE}" ENTRY "${_RAPIDS_ENTRY}" WARN_USED
                            "${_RAPIDS_WARN_USED}" WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
  elseif(matrix_type STREQUAL "ARRAY")
    _rapids_cmake_cjmp_array(result PATH "${_RAPIDS_PATH}" KEY "${_RAPIDS_KEY}" MATRIX
                             "${_RAPIDS_MATRIX}" QUEUE "${_RAPIDS_QUEUE}" ENTRY "${_RAPIDS_ENTRY}"
                             WARN_USED "${_RAPIDS_WARN_USED}" WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
  else()
    _rapids_cmake_cjmp_leaf(result PATH "${_RAPIDS_PATH}" KEY "${_RAPIDS_KEY}" MATRIX
                            "${_RAPIDS_MATRIX}" QUEUE "${_RAPIDS_QUEUE}" ENTRY "${_RAPIDS_ENTRY}"
                            WARN_USED "${_RAPIDS_WARN_USED}" WARN_UNUSED "${_RAPIDS_WARN_UNUSED}")
  endif()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cmake_compute_json_matrix_product
----------------------------------------

.. versionadded:: v25.08.00

Compute a matrix product from a JSON document.

  .. code-block:: cmake

    rapids_cmake_compute_matrix_product(
      output_var
      [MATRIX_STRING <json_string>]
      [MATRIX_FILE <json_file>]
      [NO_WARN_USED]
      [NO_WARN_UNUSED]
    )

This function takes a JSON document in the form of a string or a file. It
returns a JSON list of flat dictionaries in the output variable based on the
possible combinations of fields in the provided document. It is most commonly
used to compute a matrix of nearly-identical files to be generated from a
single input file with different placeholders filled in.

The algorithm is designed to be as intuitive as possible to use. It serves
a similar purpose to `itertools.product <https://docs.python.org/3/library/itertools.html#itertools.product>`_,
but accepts arbitrarily deep hierarchies of JSON documents rather than a
simple list of lists. It works as follows:

1. The returned value is a JSON list. Each item in the JSON list is a
   dictionary whose values are all primitive values (strings, booleans,
   numbers, and ``null``).
2. Every primitive value in the input will show up in at least one matrix
   product entry in the output. It will be stored in the field with the same
   name as the dictionary field that is the most direct ancestor to the
   value in the input. It is an error for a primitive value to not have any
   dictionaries as ancestors in the input.
3. Each list in the input will multiply the number of matrix entries in the
   output by the number of items in the list. These matrix entries will contain
   the values within each item in the list.
4. Lists and dictionaries can be nested arbitrarily deep. Dictionaries can
   be used to group related values within a list item.

For example, consider the following JSON document:

  .. code-block:: json
    {
      "a": [1, 2],
      "_group": [
        {
          "b": 3,
          "c": [4, 5]
        },
        {
          "b": 6,
          "c": [7, 8]
        }
      ]
    }

Processing this JSON document will result in the following output:

  .. code-block:: json
    [
      {"a": 1, "b": 3, "c": 4},
      {"a": 2, "b": 3, "c": 4},
      {"a": 1, "b": 3, "c": 5},
      {"a": 2, "b": 3, "c": 5},
      {"a": 1, "b": 6, "c": 7},
      {"a": 2, "b": 6, "c": 7},
      {"a": 1, "b": 6, "c": 8},
      {"a": 2, "b": 6, "c": 8},
    ]

Notice the following details of the output:

1. The ``_group`` field never appears in the output. This is because
   it is not a direct ancestor to any primitive values and is used only for
   grouping.
2. Each ``c`` field was multiplied only with its corresponding ``b`` field.
   For example, ``"b": 3`` never appears alongside ``"c": 7``.
3. Recursive descent is done in alphabetical order within the dictionary.
   Since ``a`` comes after ``_group`` when sorted, ``a`` is iterated before
   ``_group``, even though the fields within ``_group`` (``b`` and ``c``) come
   after ``a``.

The following JSON document is an error, since it contains primitive values
with no dictionary ancestors:

  .. json::
    [1, 2]

The naming convention recommended for this algorithm is that field names that
are only used for grouping and never appear in the output should start with
an underscore (``_``), while field names that do appear in the output should
not start with an underscore. Failure to follow this naming convention will
not affect the proper functioning of the algorithm, but will result in a
warning unless the corresponding ``NO_WARN_USED`` or ``NO_WARN_UNUSED``
argument is passed.

This function requires CMake 4.3 or newer.

``output_var``
  Name of the variable in which to store the JSON list output.

``MATRIX_STRING``
  String containing the JSON document to process. Mutually exclusive with
  the ``MATRIX_FILE`` argument.

``MATRIX_FILE``
  File containing the JSON document to process. Mutually exclusive with
  the ``MATRIX_STRING`` argument.

``NO_WARN_USED``
  Do not issue a warning if a field name that starts with an underscore
  appears in the output.

``NO_WARN_UNUSED``
  Do not issue a warning if a field name that does not start with an
  underscore does not appear in the output.

#]=======================================================================]
function(rapids_cmake_compute_json_matrix_product out_var)
  set(options NO_WARN_USED NO_WARN_UNUSED)
  set(one_value MATRIX_STRING MATRIX_FILE)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(_RAPIDS_MATRIX_FILE)
    if(_RAPIDS_MATRIX_STRING)
      message(FATAL_ERROR "Cannot specify both MATRIX_STRING and MATRIX_FILE")
    endif()
    file(READ "${_RAPIDS_MATRIX_FILE}" _RAPIDS_MATRIX_STRING)
  elseif(NOT _RAPIDS_MATRIX_STRING)
    message(FATAL_ERROR "Must specify at least one of MATRIX_STRING or MATRIX_FILE")
  endif()

  set(warn_used TRUE)
  if(_RAPIDS_NO_WARN_USED)
    set(warn_used FALSE)
  endif()
  set(warn_unused TRUE)
  if(_RAPIDS_NO_WARN_UNUSED)
    set(warn_unused FALSE)
  endif()

  _rapids_cmake_cjmp_impl(generator_result PATH "[]" KEY null MATRIX "${_RAPIDS_MATRIX_STRING}"
                          QUEUE "[]" ENTRY "{}" WARN_USED "${warn_used}" WARN_UNUSED
                          "${warn_unused}")

  set(result "[]")
  string(JSON len LENGTH "${generator_result}")
  set(it 0)
  while(it LESS len)
    string(JSON entry GET_RAW "${generator_result}" "${it}" entry)
    _rapids_cmake_cjmp_array_append(result "${result}" "${entry}")
    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
endfunction()
