#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2022-2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/test/gpu_requirements.cmake)

add_test(fake_test COMMAND "${CMAKE_COMMAND} -E echo")

rapids_test_gpu_requirements(fake_test GPUS 1 PERCENT 100)
