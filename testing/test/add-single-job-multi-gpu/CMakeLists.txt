#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2022-2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
cmake_minimum_required(VERSION 3.20)
project(rapids-test-project LANGUAGES CUDA)

include(${rapids-cmake-dir}/rapids-test.cmake)

rapids_test_init()

add_executable(verify_alloc main.cu)

enable_testing()
rapids_test_add(NAME simple_test COMMAND verify_alloc GPUS 2 PERCENT 75)
