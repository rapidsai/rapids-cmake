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
                   )

``NAMESPACE``
  The namespace that the Thrust target will be constructed into.

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(<PackageName> ...)` call needs to occur as part of
  our build directory export set.

``INSTALL_EXPORT_SET``
  Record a :cmake:command:`find_dependency(<PackageName> ...)` call needs to occur as part of
  our build directory export set.

.. note::
  Installation of Thrust will occur if an INSTALL_EXPORT_SET is provided, and Thrust
  is added to the project via :cmake:command:`add_subdirectory` by CPM.


Result Targets
^^^^^^^^^^^^^^
  <namespace>::Thrust target will be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`Thrust_SOURCE_DIR` is set to the path to the source directory of Thrust.
  :cmake:variable:`Thrust_BINAR_DIR`  is set to the path to the build directory of  Thrust.
  :cmake:variable:`Thrust_ADDED`      is set to a true value if Thrust has not been added before.
  :cmake:variable:`Thrust_VERSION`    is set to the version of Thrust specified by the versions.json.

#]=======================================================================]
function(rapids_cpm_thrust NAMESPACE namespaces_name)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.thrust")

  set(to_install OFF)
  if(INSTALL_EXPORT_SET IN_LIST ARGN)
    set(to_install ON)
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
  rapids_cpm_package_details(Thrust version repository tag shallow)

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(Thrust ${version} ${ARGN}
                  GLOBAL_TARGETS ${namespaces_name}::Thrust
                  CPM_ARGS
                  GIT_REPOSITORY ${repository}
                  GIT_TAG ${tag}
                  GIT_SHALLOW ${shallow}
                  OPTIONS "THRUST_ENABLE_INSTALL_RULES ${to_install}")

  if(NOT TARGET ${namespaces_name}::Thrust)
    thrust_create_target(${namespaces_name}::Thrust FROM_OPTIONS)
  endif()

  # Since `GLOBAL_TARGET ${namespaces_name}::Thrust` will list the target to be promoted to global
  # by `rapids_export` this will break consumers as the target doesn't exist when generating the
  # dependencies.cmake file, but requires a call to `thrust_create_target`
  #
  # So determine what `BUILD_EXPORT_SET` and `INSTALL_EXPORT_SET` this was added to and remove
  # ${namespaces_name}::Thrust
  set(options CPM_ARGS)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(RAPIDS_BUILD_EXPORT_SET)
    set(target_name rapids_export_build_${RAPIDS_BUILD_EXPORT_SET})
    get_target_property(global_targets ${target_name} GLOBAL_TARGETS)
    list(REMOVE_ITEM global_targets "${namespaces_name}::Thrust")
    set_target_properties(${target_name} PROPERTIES GLOBAL_TARGETS "${global_targets}")
  endif()

  if(RAPIDS_INSTALL_EXPORT_SET)
    set(target_name rapids_export_install_${RAPIDS_BUILD_EXPORT_SET})
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
