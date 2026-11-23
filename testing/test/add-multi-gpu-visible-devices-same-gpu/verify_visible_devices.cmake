# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)

# Compare the devices made visible by `run_gpu_test.cmake` against `expected_devices` ignoring the
# order in which CTest assigned them
string(REPLACE "," ";" actual "$ENV{CUDA_VISIBLE_DEVICES}")
string(REPLACE "," ";" expected "${expected_devices}")
list(SORT actual)
list(SORT expected)
if(NOT actual STREQUAL expected)
  message(FATAL_ERROR "CUDA_VISIBLE_DEVICES is '$ENV{CUDA_VISIBLE_DEVICES}' but expected '${expected_devices}'"
  )
endif()
