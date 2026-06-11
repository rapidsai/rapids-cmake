# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/find/package.cmake)
include("${rapids-cmake-testing-dir}/utils/make_fake_package_config.cmake")

make_fake_package_config(FakeGlobalFind FakeGlobalFind::Core)
make_fake_package_config(FakePlainFind FakePlainFind::Core)

set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL OFF)
rapids_find_package(FakeGlobalFind 1.0 GLOBAL_TARGETS)

if(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL)
  message(FATAL_ERROR "rapids_find_package leaked CMAKE_FIND_PACKAGE_TARGETS_GLOBAL")
endif()

get_target_property(is_global FakeGlobalFind::Core IMPORTED_GLOBAL)
if(NOT is_global)
  message(FATAL_ERROR "rapids_find_package(GLOBAL_TARGETS) failed to make all targets global")
endif()

find_package(FakePlainFind 1.0 REQUIRED)

get_target_property(is_global FakePlainFind::Core IMPORTED_GLOBAL)
if(is_global)
  message(FATAL_ERROR "rapids_find_package leaked global target behavior to a plain find_package")
endif()
