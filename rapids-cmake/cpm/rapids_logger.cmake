# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cpm_rapids_logger
------------------------

.. versionadded:: v25.02.00

Allow projects to build `rapids-logger` via `CPM`.

Uses the version of rapids-logger :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_rapids_logger( [BUILD_EXPORT_SET <export-name>]
                            [INSTALL_EXPORT_SET <export-name>]
                            [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: logger
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  rapids_logger::rapids_logger target will be created

#]=======================================================================]
function(rapids_cpm_rapids_logger)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_logger")

  include("${rapids-cmake-dir}/cpm/detail/package_info.cmake")
  rapids_cpm_package_info(rapids_logger ${ARGN} VERSION_VAR version FIND_VAR find_args CPM_VAR
                          cpm_find_info TO_INSTALL_VAR to_install)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(rapids_logger ${version} patch_command build_patch_only)

  # rapids-logger has BUILD_SHARED_LIBS as an option, so if rapids_cpm_find ends up cloning the repo
  # rather than finding a preexisting build and it runs the CMakeLists.txt it will make
  # BUILD_SHARED_LIBS a cache variable that propagates upward. That could potentially affect
  # subsequent builds. To prevent this, we set BUILD_SHARED_LIBS to OFF before calling
  # rapids_cpm_find unless the user has explicitly set BUILD_SHARED_LIBS then we will respect that
  # and not override it, but if they haven't set it then we exploit CMP0077
  # (https://cmake.org/cmake/help/latest/policy/CMP0077.html#policy:CMP0077) to ensure that
  # rapids-logger's setting doesn't propagate upwards and affect other dependencies. We set it to ON
  # because that's the default for rapids-logger.
  if(NOT DEFINED BUILD_SHARED_LIBS)
    set(BUILD_SHARED_LIBS ON)
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(rapids_logger ${version} ${find_args} CPM_ARGS ${cpm_find_info}
                  OPTIONS "BUILD_TESTS OFF")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(logger)

  # Propagate up variables that CPMFindPackage provide
  set(rapids_logger_SOURCE_DIR "${rapids_logger_SOURCE_DIR}" PARENT_SCOPE)
  set(rapids_logger_BINARY_DIR "${rapids_logger_BINARY_DIR}" PARENT_SCOPE)
  set(rapids_logger_ADDED "${rapids_logger_ADDED}" PARENT_SCOPE)
  set(rapids_logger_VERSION ${version} PARENT_SCOPE)
endfunction()
