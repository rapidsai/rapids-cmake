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
rapids_cpm_thrust
-----------------

.. versionadded:: v21.10.00

Allow projects to find or build `Thrust` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of Thrust :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_thrust( NAMESPACE <namespace>
                     [BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [<CPM_ARGS> ...])

``NAMESPACE``
  The namespace that the Thrust target will be constructed into.

.. |PKG_NAME| replace:: Thrust
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  <namespace>::Thrust target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`Thrust_SOURCE_DIR` is set to the path to the source directory of Thrust.
  :cmake:variable:`Thrust_BINARY_DIR` is set to the path to the build directory of  Thrust.
  :cmake:variable:`Thrust_ADDED`      is set to a true value if Thrust has not been added before.
  :cmake:variable:`Thrust_VERSION`    is set to the version of Thrust specified by the versions.json.

#]=======================================================================]
# cmake-lint: disable=R0915
function(rapids_cpm_thrust NAMESPACE namespaces_name)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.thrust")

  set(to_install OFF)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install ON)
    # Make sure we install thrust into the `include/rapids` subdirectory instead of the default
    include(GNUInstallDirs)
    set(CMAKE_INSTALL_INCLUDEDIR "${CMAKE_INSTALL_INCLUDEDIR}/rapids")
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(Thrust version repository tag shallow exclude)

  include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
  rapids_cpm_generate_patch_command(Thrust ${version} patch_command)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(Thrust ${version} ${ARGN}
                  GLOBAL_TARGETS ${namespaces_name}::Thrust
                  CPM_ARGS FIND_PACKAGE_ARGUMENTS EXACT
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  PATCH_COMMAND ${patch_command}
                  EXCLUDE_FROM_ALL ${exclude}
                  OPTIONS "THRUST_ENABLE_INSTALL_RULES ${to_install}")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(Thrust)

  set(options)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(Thrust_SOURCE_DIR AND _RAPIDS_BUILD_EXPORT_SET)
    # Store where CMake can find the Thrust-config.cmake that comes part of Thrust source code
    include("${rapids-cmake-dir}/export/find_package_root.cmake")
    rapids_export_find_package_root(BUILD Thrust "${Thrust_SOURCE_DIR}/cmake"
                                    ${_RAPIDS_BUILD_EXPORT_SET})
  endif()

  if(NOT TARGET ${namespaces_name}::Thrust)
    thrust_create_target(${namespaces_name}::Thrust FROM_OPTIONS)
    set_target_properties(${namespaces_name}::Thrust PROPERTIES IMPORTED_NO_SYSTEM ON)
    if(TARGET _Thrust_Thrust)
      set_target_properties(_Thrust_Thrust PROPERTIES IMPORTED_NO_SYSTEM ON)
    endif()
  endif()

  # Since `GLOBAL_TARGET ${namespaces_name}::Thrust` will list the target to be promoted to global
  # by `rapids_export` this will break consumers as the target doesn't exist when generating the
  # dependencies.cmake file, but requires a call to `thrust_create_target`
  #
  # So determine what `BUILD_EXPORT_SET` and `INSTALL_EXPORT_SET` this was added to and remove
  # ${namespaces_name}::Thrust
  if(_RAPIDS_BUILD_EXPORT_SET)
    set(target_name rapids_export_build_${_RAPIDS_BUILD_EXPORT_SET})
    get_target_property(global_targets ${target_name} GLOBAL_TARGETS)
    list(REMOVE_ITEM global_targets "${namespaces_name}::Thrust")
    set_target_properties(${target_name} PROPERTIES GLOBAL_TARGETS "${global_targets}")
  endif()

  if(_RAPIDS_INSTALL_EXPORT_SET)
    set(target_name rapids_export_install_${_RAPIDS_INSTALL_EXPORT_SET})
    get_target_property(global_targets ${target_name} GLOBAL_TARGETS)
    list(REMOVE_ITEM global_targets "${namespaces_name}::Thrust")
    set_target_properties(${target_name} PROPERTIES GLOBAL_TARGETS "${global_targets}")
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(Thrust_SOURCE_DIR "${Thrust_SOURCE_DIR}" PARENT_SCOPE)
  set(Thrust_BINARY_DIR "${Thrust_BINARY_DIR}" PARENT_SCOPE)
  set(Thrust_ADDED "${Thrust_ADDED}" PARENT_SCOPE)
  set(Thrust_VERSION ${version} PARENT_SCOPE)

endfunction()
