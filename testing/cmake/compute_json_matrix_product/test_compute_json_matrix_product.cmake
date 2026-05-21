# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

include(${rapids-cmake-dir}/cmake/compute_json_matrix_product.cmake)

rapids_cmake_compute_json_matrix_product(actual_product ${ARGS})
string(JSON equal EQUAL "${EXPECTED_PRODUCT}" "${actual_product}")
if(NOT equal)
  string(REPLACE "\n" "\n  " formatted_expected_product "${EXPECTED_PRODUCT}")
  string(REPLACE "\n" "\n  " formatted_actual_product "${actual_product}")
  message(FATAL_ERROR "Expected matrix product:\n  ${formatted_expected_product}\n Actual matrix product:\n  ${formatted_actual_product}"
  )
endif()
