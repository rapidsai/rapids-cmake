#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2022-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/test/gpu_requirements.cmake)

add_test(fake_test COMMAND "${CMAKE_COMMAND} -E echo")

rapids_test_gpu_requirements(fake_test GPUS 12 PERCENT 25)

get_test_property(fake_test RESOURCE_GROUPS value)
if(NOT value STREQUAL "12,gpus:25")
  message(FATAL_ERROR "Unexpected RESOURCE_GROUPS test property value after rapids_test_gpu_requirements"
  )
endif()
