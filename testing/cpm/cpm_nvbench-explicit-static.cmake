#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/nvbench.cmake)

rapids_cpm_init()
rapids_cpm_nvbench(BUILD_STATIC)

get_target_property(type nvbench TYPE)
if(NOT type STREQUAL STATIC_LIBRARY)
  message(FATAL_ERROR "rapids_cpm_nvbench failed to get a static version of nvbench")
endif()
