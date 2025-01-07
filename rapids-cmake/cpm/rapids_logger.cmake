#=============================================================================
# Copyright (c) 2025, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cpm_rapids_logger
------------------------

.. versionadded:: v25.02.00

Allow projects to build `rapids-logger` via `CPM`.

Uses the version of rapids-logger :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

Unlike most `rapids_cpm` functions, this one does not support export sets because rapids-logger adds targets directly to the calling project's own export set and does not require its own exporting or to be found at all by consuming projects once the first project's call to rapids_make_logger has completed.

.. code-block:: cmake

  rapids_cpm_rapids_logger( [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: logger
.. include:: common_package_args.txt

Result Functions
^^^^^^^^^^^^^^^^
  :cmake:command:`rapids_make_logger` is made available

#]=======================================================================]
function(rapids_cpm_rapids_logger)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_logger")

  # TODO: Need to also support this in exported config files so that header-only libraries like rmm
  # can force their consumers to clone spdlog when a pre-built package is found.
  if(RAPIDS_LOGGER_HIDE_ALL_SPDLOG_SYMBOLS)
    message("Hiding symbols")
    get_property(_already_downloaded_spdlog GLOBAL PROPERTY RAPIDS_LOGGER_DOWNLOADED_SPDLOG)
    if(NOT _already_downloaded_spdlog)
      message("Not downloaded")
      if(TARGET spdlog::spdlog OR TARGET spdlog::spdlog_header_only)
        message(FATAL_ERROR "Expected spdlog::spdlog not to exist before the first call to rapids_cpm_rapids_logger when RAPIDS_LOGGER_HIDE_ALL_SPDLOG_SYMBOLS is ON"
        )
      endif()
      set(CPM_DOWNLOAD_spdlog ON)
      include(${rapids-cmake-dir}/cpm/spdlog.cmake)
      message("Calling spdlog")
      rapids_cpm_spdlog(FMT_OPTION "BUNDLED"
                        # TODO: Get the export sets as input
                        INSTALL_EXPORT_SET ${_RAPIDS_EXPORT_SET}
                        BUILD_EXPORT_SET ${_RAPIDS_EXPORT_SET}
                                         # TODO: I don't really expect this to work with the way
                                         # that rapids_cpm_spdlog is set up right now, it's going to
                                         # require some tweaking of argument forwarding I suspect.
                                         CPM_ARGS EXCLUDE_FROM_ALL ON OPTIONS
                                         "BUILD_SHARED_LIBS OFF" "SPDLOG_BUILD_SHARED OFF")
      set_property(GLOBAL PROPERTY RAPIDS_LOGGER_DOWNLOADED_SPDLOG ON)
    endif()
  endif()

  set(options)
  set(one_value)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(rapids_logger version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(rapids_logger ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(rapids_logger ${version} ${_RAPIDS_UNPARSED_ARGUMENTS}
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow} ${patch_command}
                  EXCLUDE_FROM_ALL ON)

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(logger)
endfunction()
