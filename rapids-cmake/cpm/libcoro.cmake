# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# rapids-pre-commit-hooks: disable[verify-hardcoded-version]
#[=======================================================================[.rst:
rapids_cpm_libcoro
------------------

.. versionadded:: v26.08.00

Allow projects to find or build `libcoro` via `CPM` with built-in
tracking of these dependencies for correct export support.

libcoro is a C++20 coroutine library.

Uses the version of libcoro :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_libcoro( [BUILD_EXPORT_SET <export-name>]
                      [INSTALL_EXPORT_SET <export-name>]
                      [EXCLUDE_FROM_ALL]
                      [BUILD_STATIC]
                      [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: libcoro
.. include:: common_package_args.txt

``BUILD_STATIC``
  Will build `libcoro` statically. No local searching for a previously
  built version will occur.

Result Targets
^^^^^^^^^^^^^^
  libcoro::libcoro target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`libcoro_SOURCE_DIR` is set to the path to the source directory of libcoro.
  :cmake:variable:`libcoro_BINARY_DIR` is set to the path to the build directory of libcoro.
  :cmake:variable:`libcoro_ADDED`      is set to a true value if libcoro has not been added before.
  :cmake:variable:`libcoro_VERSION`    is set to the version of libcoro specified by the versions.json.

#]=======================================================================]
# rapids-pre-commit-hooks: enable[verify-hardcoded-version]
function(rapids_cpm_libcoro)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.libcoro")

  set(build_shared ON)
  if(BUILD_STATIC IN_LIST ARGN)
    set(build_shared OFF)
    set(CPM_DOWNLOAD_libcoro ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_info.cmake")
  rapids_cpm_package_info(libcoro ${ARGN} VERSION_VAR version FIND_VAR find_args CPM_VAR
                          cpm_find_info TO_INSTALL_VAR to_install)

  set(_rapids_libcoro_orig_build_shared_libs ${BUILD_SHARED_LIBS})

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(libcoro ${version} ${find_args}
                  GLOBAL_TARGETS libcoro::libcoro
                  CPM_ARGS ${cpm_find_info}
                  OPTIONS "LIBCORO_BUILD_SHARED_LIBS ${build_shared}"
                          "LIBCORO_EXTERNAL_DEPENDENCIES OFF"
                          "LIBCORO_FEATURE_NETWORKING OFF"
                          "LIBCORO_FEATURE_TLS OFF"
                          "LIBCORO_BUILD_TESTS OFF"
                          "LIBCORO_BUILD_EXAMPLES OFF"
                          "CMAKE_POSITION_INDEPENDENT_CODE ON")

  # cmake-lint: disable=C0103
  set(BUILD_SHARED_LIBS ${_rapids_libcoro_orig_build_shared_libs} CACHE INTERNAL "" FORCE)

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(libcoro)

  if(libcoro_ADDED AND TARGET libcoro)
    set_property(TARGET libcoro PROPERTY SYSTEM TRUE)
  endif()

  if(NOT TARGET libcoro::libcoro AND TARGET libcoro)
    add_library(libcoro::libcoro ALIAS libcoro)
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(libcoro_SOURCE_DIR "${libcoro_SOURCE_DIR}" PARENT_SCOPE)
  set(libcoro_BINARY_DIR "${libcoro_BINARY_DIR}" PARENT_SCOPE)
  set(libcoro_ADDED "${libcoro_ADDED}" PARENT_SCOPE)
  set(libcoro_VERSION ${version} PARENT_SCOPE)

endfunction()
