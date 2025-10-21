#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cmake/build_type.cmake)

rapids_cmake_build_type(DEBUG)
rapids_cmake_build_type(RELEASE)

if(CMAKE_CONFIGURATION_TYPES)
  if(DEFINED CMAKE_BUILD_TYPE)
    message(FATAL_ERROR "rapids_cmake_build_type failed when executed by a multi-config generator")
  endif()
elseif(NOT CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  message(FATAL_ERROR "rapids_cmake_build_type failed")
endif()
