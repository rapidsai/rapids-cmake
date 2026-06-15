# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

# rapids-pre-commit-hooks: disable[verify-hardcoded-version]
#[=======================================================================[.rst:
rapids_cmake_check_conda_env
----------------------------

.. versionadded:: v26.08.00

Detect when the active Conda environment has changed since the build directory was initially configured.

  .. code-block:: cmake

    rapids_cmake_check_conda_env([REBUILD_INSTRUCTION <instruction>])

When called from within a Conda environment, records the current ``CONDA_PREFIX`` in the
internal cache variable ``rapids_conda_prefix``. On subsequent configures, if ``CONDA_PREFIX``
differs from the recorded value, configure terminates with a fatal error that includes
``REBUILD_INSTRUCTION`` for the user.

``REBUILD_INSTRUCTION``
  Instructions shown to the user on how to delete the build directory and reconfigure. If not provided, a
  default instruction ``rm -rf <build directory>`` is used.

#]=======================================================================]
# rapids-pre-commit-hooks: enable[verify-hardcoded-version]
function(rapids_cmake_check_conda_env)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.check_conda_env")

  set(options)
  set(one_value REBUILD_INSTRUCTION)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED _RAPIDS_REBUILD_INSTRUCTION)
    set(_RAPIDS_REBUILD_INSTRUCTION "rm -rf ${CMAKE_BINARY_DIR}")
  endif()

  if(DEFINED ENV{CONDA_PREFIX})
    set(_current_conda "$ENV{CONDA_PREFIX}")
    if(DEFINED rapids_conda_prefix AND NOT _current_conda STREQUAL "${rapids_conda_prefix}")
      message(FATAL_ERROR "Conda environment changed since this build directory was configured.\n"
                          "  Configured with: ${rapids_conda_prefix}\n"
                          "  Current env:     ${_current_conda}\n"
                          "Delete the build directory and reconfigure:\n"
                          "  ${_RAPIDS_REBUILD_INSTRUCTION}")
    endif()
    set(rapids_conda_prefix "${_current_conda}"
        CACHE INTERNAL
              "Conda prefix at initial configure time; used to detect environment mismatches")
  endif()
endfunction()
