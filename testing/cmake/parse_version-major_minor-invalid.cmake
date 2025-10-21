#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cmake/parse_version.cmake)

rapids_cmake_parse_version(MAJOR_MINOR "" major_minor)
if(DEFINED major_minor)
  message(FATAL_ERROR "rapids_cmake_parse_version(MAJOR_MINOR) value parsing should have failed")
endif()

rapids_cmake_parse_version(MAJOR_MINOR "not-a-version" major_minor)
if(DEFINED major_minor)
  message(FATAL_ERROR "rapids_cmake_parse_version(MAJOR_MINOR) value parsing failed unexpectedly")
endif()

rapids_cmake_parse_version(MAJOR_MINOR "100" major_minor)
if(DEFINED major_minor)
  message(FATAL_ERROR "rapids_cmake_parse_version(MAJOR_MINOR) value parsing failed unexpectedly")
endif()

rapids_cmake_parse_version(MAJOR_MINOR "100." major_minor)
if(DEFINED major_minor)
  message(FATAL_ERROR "rapids_cmake_parse_version(MAJOR_MINOR) value parsing failed unexpectedly")
endif()

rapids_cmake_parse_version(MAJOR_MINOR "100.." major_minor)
if(DEFINED major_minor)
  message(FATAL_ERROR "rapids_cmake_parse_version(MAJOR_MINOR) value parsing failed unexpectedly")
endif()
