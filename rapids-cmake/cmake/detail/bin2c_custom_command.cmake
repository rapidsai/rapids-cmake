# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

include("${CMAKE_CURRENT_LIST_DIR}/../bin2c.cmake")

set(static)
if(BIN2C_STATIC)
  set(static STATIC)
endif()

set(const)
if(BIN2C_CONST)
  set(const CONST)
endif()

set(row_width)
if(BIN2C_ROW_WIDTH)
  set(row_width ROW_WIDTH ${BIN2C_ROW_WIDTH})
endif()

rapids_cmake_bin2c("${BIN2C_OUTPUT_FILE}" "${BIN2C_INPUT_FILE}" "${BIN2C_ARRAY_NAME}" ${static}
                   ${const} ${row_width})
