# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cmake_bin2c
------------------

.. versionadded:: v26.02.00

Convert a binary file to a C array file, just like the bin2c utility.

  .. code-block:: cmake

    rapids_cmake_bin2c( output_file input_file variable_name [STATIC] [CONST] [ROW_WIDTH <row-width>] )

#]=======================================================================]
function(rapids_cmake_bin2c output_file input_file array_name)
  set(options STATIC CONST)
  set(one_value ROW_WIDTH)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED _RAPIDS_ROW_WIDTH)
    set(_RAPIDS_ROW_WIDTH 32)
  endif()

  file(READ "${input_file}" contents HEX)
  string(LENGTH "${contents}" contents_length)
  math(EXPR hex_row_width "${_RAPIDS_ROW_WIDTH} * 2")

  set(bytes)
  foreach(row_start RANGE 0 "${contents_length}" "${hex_row_width}")
    message(STATUS "row_start=${row_start}")
    math(EXPR row_end "${row_start} + ${hex_row_width}")
    if(row_end GREATER_EQUAL contents_length)
      math(EXPR row_end "${contents_length}")
    endif()

    if(row_end GREATER row_start)
      math(EXPR row_end "${row_end} - 2")
      string(APPEND bytes "\n  ")
      foreach(index RANGE "${row_start}" "${row_end}" 2)
        string(SUBSTRING "${contents}" "${index}" 2 byte)
        string(APPEND bytes "0x${byte},")
      endforeach()
    endif()
  endforeach()

  set(static "")
  if(_RAPIDS_STATIC)
    set(static "static ")
  endif()

  set(const "")
  if(_RAPIDS_CONST)
    set(const "const ")
  endif()

  string(TIMESTAMP current_year "%Y")
  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/bin2c.h.in" "${output_file}" @ONLY)
endfunction()

#[=======================================================================[.rst:
rapids_cmake_bin2c_custom_command
---------------------------------

.. versionadded:: v26.02.00

Convert a binary file to a C array file, just like the bin2c utility.

Takes the same arguments as :cmake:command:`rapids_cmake_bin2c`, but executes at build time via
a custom command rather than configure time.

  .. code-block:: cmake

    rapids_cmake_bin2c_custom_command( output_file input_file variable_name [STATIC] [CONST] [ROW_WIDTH <row-width>] )

#]=======================================================================]
function(rapids_cmake_bin2c_custom_command output_file input_file array_name)
  set(options STATIC CONST)
  set(one_value ROW_WIDTH)
  set(multi_value)

  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(row_width)
  if(DEFINED _RAPIDS_ROW_WIDTH)
    set(row_width "-DBIN2C_ROW_WIDTH=${_RAPIDS_ROW_WIDTH}")
  endif()

  add_custom_command(OUTPUT "${output_file}"
                     COMMAND "${CMAKE_COMMAND}" "-DBIN2C_OUTPUT_FILE=${output_file}"
                             "-DBIN2C_INPUT_FILE=${input_file}" "-DBIN2C_ARRAY_NAME=${array_name}"
                             "-DBIN2C_STATIC=${_RAPIDS_STATIC}" "-DBIN2C_CONST=${_RAPIDS_CONST}"
                             ${row_width} -P
                             "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/bin2c_custom_command.cmake"
                     DEPENDS "${input_file}"
                     COMMENT "Convert ${input_file} to C array")
endfunction()
