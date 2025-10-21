#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/gbench.cmake)

rapids_cpm_init()
rapids_cpm_gbench(BUILD_STATIC)

get_target_property(type benchmark TYPE)
if(NOT type STREQUAL STATIC_LIBRARY)
  message(FATAL_ERROR "rapids_cpm_gbench failed to get a static version of gbench")
endif()
