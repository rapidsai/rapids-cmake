# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/find.cmake)
include("${rapids-cmake-testing-dir}/utils/make_fake_package_config.cmake")

cmake_minimum_required(VERSION 4.0)
project(rapids-cpm-global-targets-no-values LANGUAGES CXX)

make_fake_package_config(FakeGlobalCpm FakeGlobalCpm::Core)
make_fake_package_config(FakePlainCpm FakePlainCpm::Core)

rapids_cpm_init()

set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL OFF)
rapids_cpm_find(FakeGlobalCpm 1.0 GLOBAL_TARGETS CPM_ARGS)

if(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL)
  message(FATAL_ERROR "rapids_cpm_find leaked CMAKE_FIND_PACKAGE_TARGETS_GLOBAL")
endif()

get_target_property(is_global FakeGlobalCpm::Core IMPORTED_GLOBAL)
if(NOT is_global)
  message(FATAL_ERROR "rapids_cpm_find(GLOBAL_TARGETS) failed to make all targets global")
endif()

find_package(FakePlainCpm 1.0 REQUIRED)

get_target_property(is_global FakePlainCpm::Core IMPORTED_GLOBAL)
if(is_global)
  message(FATAL_ERROR "rapids_cpm_find leaked global target behavior to a plain find_package")
endif()
