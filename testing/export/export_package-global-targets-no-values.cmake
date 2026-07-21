# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/export/package.cmake)
include(${rapids-cmake-dir}/export/write_dependencies.cmake)
include("${rapids-cmake-testing-dir}/utils/make_fake_package_config.cmake")

make_fake_package_config(FakeExportGlobal FakeExportGlobal::Core)
make_fake_package_config(FakeExportPlain FakeExportPlain::Core)

rapids_export_package(BUILD FakeExportGlobal behavior_set GLOBAL_TARGETS)
rapids_export_package(BUILD FakeExportPlain behavior_set)
rapids_export_write_dependencies(BUILD behavior_set
                                 "${CMAKE_CURRENT_BINARY_DIR}/behavior_export_set.cmake")

set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL OFF)
include("${CMAKE_CURRENT_BINARY_DIR}/behavior_export_set.cmake")

if(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL)
  message(FATAL_ERROR "rapids_export_package leaked CMAKE_FIND_PACKAGE_TARGETS_GLOBAL")
endif()

get_target_property(is_global FakeExportGlobal::Core IMPORTED_GLOBAL)
if(NOT is_global)
  message(FATAL_ERROR "rapids_export_package(GLOBAL_TARGETS) failed to make all targets global")
endif()

get_target_property(is_global FakeExportPlain::Core IMPORTED_GLOBAL)
if(is_global)
  message(FATAL_ERROR "rapids_export_package leaked global target behavior to another dependency")
endif()

rapids_export_package(INSTALL FakeInstallGlobal install_set GLOBAL_TARGETS)
rapids_export_write_dependencies(INSTALL install_set
                                 "${CMAKE_CURRENT_BINARY_DIR}/install_set.cmake")

set(path "${CMAKE_CURRENT_BINARY_DIR}/install_set.cmake")
file(READ "${path}" contents)
string(FIND "${contents}" "CMAKE_FIND_PACKAGE_TARGETS_GLOBAL" found)
if(found EQUAL -1)
  message(FATAL_ERROR "rapids_export_package(INSTALL GLOBAL_TARGETS) didn't scope global targets")
endif()
