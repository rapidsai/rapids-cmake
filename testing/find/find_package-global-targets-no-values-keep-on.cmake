# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/find/package.cmake)
include("${rapids-cmake-testing-dir}/utils/make_fake_package_config.cmake")

make_fake_package_config(FakeAlreadyGlobalFind FakeAlreadyGlobalFind::Core)
make_fake_package_config(FakeAlreadyPlainFind FakeAlreadyPlainFind::Core)

set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL ON)
rapids_find_package(FakeAlreadyGlobalFind 1.0 GLOBAL_TARGETS)

if(NOT CMAKE_FIND_PACKAGE_TARGETS_GLOBAL)
  message(FATAL_ERROR "rapids_find_package failed to preserve CMAKE_FIND_PACKAGE_TARGETS_GLOBAL")
endif()

get_target_property(is_global FakeAlreadyGlobalFind::Core IMPORTED_GLOBAL)
if(NOT is_global)
  message(FATAL_ERROR "rapids_find_package(GLOBAL_TARGETS) failed to preserve global targets")
endif()

find_package(FakeAlreadyPlainFind 1.0 REQUIRED)

get_target_property(is_global FakeAlreadyPlainFind::Core IMPORTED_GLOBAL)
if(NOT is_global)
  message(FATAL_ERROR "rapids_find_package broke caller-enabled global target behavior")
endif()
