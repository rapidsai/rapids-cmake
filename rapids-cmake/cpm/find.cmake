#=============================================================================
# Copyright (c) 2020-2021, NVIDIA CORPORATION.
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
rapids_cpm_find
---------------

.. versionadded:: v21.06.00

Allow projects to find or build a dependency via `CPM` with built-in
tracking of these dependencies for correct export support.

.. code-block:: cmake

  rapids_cpm_find(<PackageName> <version>
                  [GLOBAL_TARGETS <targets...>]
                  [BUILD_EXPORT_SET <export-name>]
                  [INSTALL_EXPORT_SET <export-name>]
                  <CPM_ARGS>
                    all normal CPM options
                )

Generate a CPM FindPackage call and associate this with the listed
build and install export set for correct export generation.

Since the visibility of CMake's targets differ between targets built locally and those
imported, :cmake:command:`rapids_cpm_find` promotes imported targets to be global so users have
consistency. List all targets used by your project in `GLOBAL_TARGET`.

.. note::
  Requires :cmake:command:`rapids_cpm_init` to be called before usage

``PackageName``
  Name of the package to find.

``version``
  Version of the package you would like CPM to find.

``GLOBAL_TARGETS``
  Which targets from this package should be made global. This information
  will be propagated to any associated export set.

  .. versionchanged:: v21.10.00
    If any targets listed in `GLOBAL_TARGET` exist when :cmake:command:`rapids_cpm_find` is called
    no calls to `CPM` will be executed. This is done for the following reasons:

      - Removes the need for the calling code to do the conditional checks
      - Allows `BUILD_EXPORT_SET` and `INSTALL_EXPORT_SET` tracking to happen correctly when targets had already been brought it by non-CPM means.

``BUILD_EXPORT_SET``
  Record that a :cmake:command:`CPMFindPackage(<PackageName> ...)` call needs to occur as part of
  our build directory export set.

``INSTALL_EXPORT_SET``
  Record a :cmake:command:`find_dependency(<PackageName> ...)` call needs to occur as part of
  our install directory export set.

``CPM_ARGS``
  Required placeholder to be provied before any extra arguments that need to
  be passed down to :cmake:command:`CPMFindPackage`.

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`<PackageName>_SOURCE_DIR` is set to the path to the source directory of <PackageName>.
  :cmake:variable:`<PackageName>_BINAR_DIR`  is set to the path to the build directory of  <PackageName>.
  :cmake:variable:`<PackageName>_ADDED`      is set to a true value if <PackageName> has not been added before.

.. note::
  Adding an export set to :cmake:command:`rapids_cpm_find` has different behavior
  for build and install. Build exports a respective CPM call, since
  we presume other CPM packages don't generate a correct build directory
  config module. While install exports a `find_dependency` call as
  we expect projects to have a valid install setup.

  If you need different behavior you will need to use :cmake:command:`rapids_export_package()`
  or :cmake:command:`rapids_export_cpm()`.

  If :cmake:variable:`CPM_<PackageName>_SOURCE` is set, we use :cmake:command:`CPMAddPackage` instead of
  :cmake:command:`CPMFindPackage`. :cmake:command:`CPMAddPackage` always adds the package at the desired
  :cmake:variable:`CPM_<PackageName>_SOURCE` location, and won't attempt to locate it via
  :cmake:command:`find_package()` first.


#]=======================================================================]
function(rapids_cpm_find name version)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.find")
  set(options CPM_ARGS)
  set(one_value BUILD_EXPORT_SET INSTALL_EXPORT_SET)
  set(multi_value GLOBAL_TARGETS)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED RAPIDS_CPM_ARGS)
    message(FATAL_ERROR "rapids_cpm_find requires you to specify CPM_ARGS before any CPM arguments")
  endif()

  set(package_needs_to_be_added TRUE)
  if(RAPIDS_GLOBAL_TARGETS)
    foreach(target IN LISTS RAPIDS_GLOBAL_TARGETS)
      if(TARGET ${target})
        set(package_needs_to_be_added FALSE)
        break()
      endif()
    endforeach()
  endif()

  if(package_needs_to_be_added)
    if(CPM_${name}_SOURCE)
      CPMAddPackage(NAME ${name} VERSION ${version} ${RAPIDS_UNPARSED_ARGUMENTS})
    else()
      CPMFindPackage(NAME ${name} VERSION ${version} ${RAPIDS_UNPARSED_ARGUMENTS})
    endif()
  endif()

  set(extra_info)
  if(RAPIDS_GLOBAL_TARGETS)
    include("${rapids-cmake-dir}/cmake/make_global.cmake")
    rapids_cmake_make_global(RAPIDS_GLOBAL_TARGETS)

    set(extra_info "GLOBAL_TARGETS")
    list(APPEND extra_info ${RAPIDS_GLOBAL_TARGETS})
  endif()

  if(RAPIDS_BUILD_EXPORT_SET)
    include("${rapids-cmake-dir}/export/cpm.cmake")
    rapids_export_cpm(BUILD ${name} ${RAPIDS_BUILD_EXPORT_SET}
                      CPM_ARGS NAME ${name} VERSION ${version} ${RAPIDS_UNPARSED_ARGUMENTS}
                               ${extra_info})
  endif()

  if(RAPIDS_INSTALL_EXPORT_SET)
    include("${rapids-cmake-dir}/export/package.cmake")
    rapids_export_package(INSTALL ${name} ${RAPIDS_INSTALL_EXPORT_SET} ${extra_info})
  endif()

  # Propagate up variables that CPMFindPackage provide
  set(${name}_SOURCE_DIR "${${name}_SOURCE_DIR}" PARENT_SCOPE)
  set(${name}_BINARY_DIR "${${name}_BINARY_DIR}" PARENT_SCOPE)
  set(${name}_ADDED "${${name}_ADDED}" PARENT_SCOPE)

endfunction()
