#=============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
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
rapids_cpm_libcudacxx
---------------------

.. versionadded:: v21.12.00

Allow projects to find or build `libcudacxx` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of libcudacxx :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_libcudacxx( [BUILD_EXPORT_SET <export-name>]
                         [INSTALL_EXPORT_SET <export-name>]
                         [<CPM_ARGS> ...])

.. |PKG_NAME| replace:: libcudacxx
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  libcudacxx::libcudacxx target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`libcudacxx_SOURCE_DIR` is set to the path to the source directory of libcudacxx.
  :cmake:variable:`libcudacxx_BINARY_DIR` is set to the path to the build directory of  libcudacxx.
  :cmake:variable:`libcudacxx_ADDED`      is set to a true value if libcudacxx has not been added before.
  :cmake:variable:`libcudacxx_VERSION`    is set to the version of libcudacxx specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_libcudacxx)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.libcudacxx")

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(libcudacxx version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(libcudacxx ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(libcudacxx ${version} ${ARGN}
                  GLOBAL_TARGETS libcudacxx::libcudacxx
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${exclude})

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(libcudacxx)

  set(options)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(libcudacxx_SOURCE_DIR AND _RAPIDS_BUILD_EXPORT_SET)
    # Store where CMake can find our custom libcudacxx
    include("${rapids-cmake-dir}/export/find_package_root.cmake")
    rapids_export_find_package_root(BUILD libcudacxx "${libcudacxx_SOURCE_DIR}/lib/cmake"
                                    ${_RAPIDS_BUILD_EXPORT_SET})
  endif()

  if(libcudacxx_SOURCE_DIR AND _RAPIDS_INSTALL_EXPORT_SET AND NOT exclude)
    # By default if we allow libcudacxx to install into `CMAKE_INSTALL_INCLUDEDIR` alongside rmm (or
    # other pacakges) we will get a install tree that looks like this:

    # install/include/rmm install/include/cub install/include/libcudacxx

    # This is a problem for CMake+NVCC due to the rules around import targets, and user/system
    # includes. In this case both rmm and libcudacxx will specify an include path of
    # `install/include`, while libcudacxx tries to mark it as an user include, since rmm uses
    # CMake's default of system include. Compilers when provided the same include as both user and
    # system always goes with system.

    # Now while rmm could also mark `install/include` as system this just pushes the issue to
    # another dependency which isn't built by RAPIDS and comes by and marks `install/include` as
    # system.

    # Instead the more reliable option is to make sure that we get libcudacxx to be placed in an
    # unique include path that the other project will use. In the case of rapids-cmake we install
    # the headers to `include/rapids/libcudacxx`
    include(GNUInstallDirs)
    set(CMAKE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/rapids/libcudacxx")

    # libcudacxx 1.8 has a bug where it doesn't generate proper exclude rules for the
    # `[cub|libcudacxx]-header-search` files, which causes the build tree version to be installed
    # instead of the install version
    if(NOT EXISTS "${libcudacxx_BINARY_DIR}/cmake/libcudacxxInstallRulesForRapids.cmake")
      file(READ "${libcudacxx_SOURCE_DIR}/cmake/libcudacxxInstallRules.cmake" contents)
      string(REPLACE "PATTERN cub-header-search EXCLUDE" "REGEX cub-header-search.* EXCLUDE"
                     contents "${contents}")
      string(REPLACE "PATTERN libcudacxx-header-search EXCLUDE"
                     "REGEX libcudacxx-header-search.* EXCLUDE" contents "${contents}")
      file(WRITE "${libcudacxx_BINARY_DIR}/cmake/libcudacxxInstallRulesForRapids.cmake" ${contents})
    endif()
    set(libcudacxx_ENABLE_INSTALL_RULES ON)
    include("${libcudacxx_BINARY_DIR}/cmake/libcudacxxInstallRulesForRapids.cmake")
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(libcudacxx_SOURCE_DIR "${libcudacxx_SOURCE_DIR}" PARENT_SCOPE)
  set(libcudacxx_BINARY_DIR "${libcudacxx_BINARY_DIR}" PARENT_SCOPE)
  set(libcudacxx_ADDED "${libcudacxx_ADDED}" PARENT_SCOPE)
  set(libcudacxx_VERSION ${version} PARENT_SCOPE)

endfunction()
