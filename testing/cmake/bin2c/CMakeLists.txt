# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/bin2c.cmake)

cmake_minimum_required(VERSION 3.30.4)
project(bin2c_test NONE)

string(TIMESTAMP year "%Y")

function(test_bin2c name filename expected_contents)
  rapids_cmake_bin2c("${CMAKE_CURRENT_BINARY_DIR}/${name}_configure.h"
                     "${CMAKE_CURRENT_SOURCE_DIR}/${filename}" ${ARGN})

  file(READ "${CMAKE_CURRENT_BINARY_DIR}/${name}_configure.h" contents)
  string(CONFIGURE [==[/*
 * SPDX-FileCopyrightText: Copyright (c) @year@, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifdef __cplusplus
extern "C" {
#endif

@expected_contents@

#ifdef __cplusplus
}
#endif
]==]
                   expected_full_contents)
  if(NOT contents STREQUAL expected_full_contents)
    string(REPLACE "\n" "\n  " message_contents "${contents}")
    string(REPLACE "\n" "\n  " message_expected_full_contents "${expected_full_contents}")
    message(SEND_ERROR "Expected for ${name}:\n  ${message_expected_full_contents}\n  Actual for ${name}:\n  ${message_contents}"
    )
  endif()

  file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/${name}_custom_command.h")
  rapids_cmake_bin2c_custom_command("${CMAKE_CURRENT_BINARY_DIR}/${name}_custom_command.h"
                                    "${CMAKE_CURRENT_SOURCE_DIR}/${filename}" ${ARGN})
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${name}_expected.h" "${expected_full_contents}")
  add_custom_target("${name}-check" ALL
                    "${CMAKE_COMMAND}" -E compare_files
                    "${CMAKE_CURRENT_BINARY_DIR}/${name}_custom_command.h"
                    "${CMAKE_CURRENT_BINARY_DIR}/${name}_expected.h"
                    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${name}_custom_command.h")
endfunction()

test_bin2c(basic text.txt [==[unsigned char bin2c_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==] bin2c_test)

test_bin2c(const text.txt [==[const unsigned char const_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==] const_test CONST)

test_bin2c(static text.txt [==[static unsigned char static_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==] static_test STATIC)

test_bin2c(static-const text.txt [==[static const unsigned char static_const_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==] static_const_test STATIC CONST)

test_bin2c(row-width
           text.txt
           [==[unsigned char row_width_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,
  0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==]
           row_width_test
           ROW_WIDTH
           8)

test_bin2c(exact-row-width-1 text.txt [==[unsigned char exact_row_width_1_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==] exact_row_width_1_test ROW_WIDTH 14)

test_bin2c(exact-row-width-2
           text.txt
           [==[unsigned char exact_row_width_2_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,
  0x77,0x6f,0x72,0x6c,0x64,0x21,0x0a,
};]==]
           exact_row_width_2_test
           ROW_WIDTH
           7)

test_bin2c(row-width-minus-1
           text.txt
           [==[unsigned char row_width_minus_1_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21,
  0x0a,
};]==]
           row_width_minus_1_test
           ROW_WIDTH
           13)

test_bin2c(row-width-minus-2
           text.txt
           [==[unsigned char row_width_minus_2_test[] = {
  0x48,0x65,0x6c,0x6c,0x6f,0x2c,0x20,0x77,0x6f,0x72,0x6c,0x64,
  0x21,0x0a,
};]==]
           row_width_minus_2_test
           ROW_WIDTH
           12)

test_bin2c(empty empty.txt [==[unsigned char empty_test[] = {
};]==] empty_test)
