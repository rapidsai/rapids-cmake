# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_json_compute_matrix_product
----------------------------------

.. versionadded:: v25.08.00

Compute a matrix product from a JSON document.

  .. code-block:: cmake

    rapids_json_compute_matrix_product(
      out_var
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
          "c": [7, 8, 9]
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
      {"a": 1, "b": 6, "c": 9},
      {"a": 2, "b": 6, "c": 9}
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

  .. code-block:: json

    [1, 2]

The naming convention recommended for this algorithm is that field names that
are only used for grouping and never appear in the output should start with
an underscore (``_``), while field names that do appear in the output should
not start with an underscore. Failure to follow this naming convention will
not affect the proper functioning of the algorithm, but will result in a
warning unless the corresponding ``NO_WARN_USED`` or ``NO_WARN_UNUSED``
argument is passed.

This function requires CMake 4.3 or newer.

``out_var``
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
function(rapids_json_compute_matrix_product out_var)
  # TODO: Remove this version gate once we require 4.3
  block(SCOPE_FOR POLICIES)
  cmake_minimum_required(VERSION 4.3)

  include("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/compute_matrix_product_impl.cmake")

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

  _rapids_json_cmp_impl(generator_result PATH "[]" KEY null MATRIX "${_RAPIDS_MATRIX_STRING}" QUEUE
                        "[]" ENTRY "{}" WARN_USED "${warn_used}" WARN_UNUSED "${warn_unused}")

  set(result "[]")
  string(JSON len LENGTH "${generator_result}")
  set(it 0)
  while(it LESS len)
    string(JSON entry GET_RAW "${generator_result}" "${it}" entry)
    rapids_json_array_append(result "${result}" "${entry}")
    math(EXPR it "${it} + 1")
  endwhile()

  set(${out_var} "${result}" PARENT_SCOPE)
  endblock()
endfunction()
