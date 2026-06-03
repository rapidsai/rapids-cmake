# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/export/cpm.cmake)

rapids_export_cpm(BUILD FakeBuildCpm template_set GLOBAL_TARGETS
                  CPM_ARGS NAME FakeBuildCpm VERSION 1.0)
rapids_export_cpm(INSTALL FakeInstallCpm template_set GLOBAL_TARGETS
                  CPM_ARGS NAME FakeInstallCpm VERSION 1.0)

get_target_property(build_global_targets rapids_export_build_template_set GLOBAL_TARGETS)
if(build_global_targets)
  message(FATAL_ERROR "rapids_export_cpm recorded explicit GLOBAL_TARGETS for zero-value input")
endif()

get_target_property(install_global_targets rapids_export_install_template_set GLOBAL_TARGETS)
if(install_global_targets)
  message(FATAL_ERROR "rapids_export_cpm recorded explicit GLOBAL_TARGETS for zero-value input")
endif()

foreach(path
        "${CMAKE_BINARY_DIR}/rapids-cmake/template_set/build/cpm_FakeBuildCpm.cmake"
        "${CMAKE_BINARY_DIR}/rapids-cmake/template_set/install/cpm_FakeInstallCpm.cmake")
  file(READ "${path}" contents)
  string(FIND "${contents}" "CMAKE_FIND_PACKAGE_TARGETS_GLOBAL" found)
  if(found EQUAL -1)
    message(FATAL_ERROR "Expected ${path} to scope CMAKE_FIND_PACKAGE_TARGETS_GLOBAL")
  endif()
endforeach()
