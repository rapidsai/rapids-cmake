# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_export_cpm
-----------------

.. versionadded:: v21.06.00

Record a given <PackageName> found by `CPMFindPackage` is required for a
given export set

.. code-block:: cmake

  rapids_export_cpm( (BUILD|INSTALL)
                      <PackageName>
                      <ExportSet>
                      CPM_ARGS <standard cpm args>
                      [GLOBAL_TARGETS <targets...>]
                      )


Records a given <PackageName> found by `CPMFindPackage` is required for a
given export set. When the associated :cmake:command:`rapids_export(BUILD|INSTALL)` or
:cmake:command:`rapids_export_write_dependencies(BUILD|INSTALL)` command is invoked the
generated information will include a :cmake:command:`CPMFindPackage` call for <PackageName>.


``BUILD``
  Will record <PackageName> is part of the build directory export set

``INSTALL``
  Will record <PackageName> is part of the build directory export set

  .. note::
    It is an anti-pattern to use this command with `INSTALL` as most CMake
    based projects should be installed, and :cmake:command:`rapids_export_package(INSTALL` used
    to find it. Only use :cmake:command:`rapids_export_cpm(INSTALL` when the above pattern
    doesn't work for some reason.


#]=======================================================================]
function(rapids_export_cpm type name export_set)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.cpm")

  string(TOLOWER ${type} type)
  string(TOLOWER ${name} lowercase_name)

  set(options "")
  set(one_value EXPORT_SET)
  set(multi_value GLOBAL_TARGETS CPM_ARGS)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(type STREQUAL build)

    # Check if we have any of the support build directory config files first
    FetchContent_GetProperties(${name} BINARY_DIR possible_build_dirs)
    list(APPEND possible_build_dirs "${${name}_BINARY_DIR}")

    set(possible_build_config_files "${lowercase_name}-config.cmake" "${name}Config.cmake")
    set(build_dir_config_found FALSE)
    foreach(bdir IN LISTS possible_build_dirs)
      foreach(config_file IN LISTS possible_build_config_files)
        if(EXISTS "${bdir}/${config_file}")
          set(build_dir_config_found TRUE)
          set(build_dir_config "${bdir}")
          break()
        endif()
      endforeach()
      if(build_dir_config_found)
        break()
      endif()
    endforeach()

    if(NOT build_dir_config_found)
      # Only when we `<package>_DIR` do we want to see if we can use the FetchContent info. This
      # maintains compatibility with projects where we need to fall-back to the build directory
      set(possible_src_dir "${${name}_DIR}")
      if(${name}_DIR)
        set(possible_dir "${${name}_DIR}")
        if(possible_dir STREQUAL CMAKE_FIND_PACKAGE_REDIRECTS_DIR)
          FetchContent_GetProperties(${name} SOURCE_DIR possible_dir)
        endif()
      else()
        # Currently required to keep the DIR hints consistent when no src or build dir exists
        # (export_cpm-build-possible-dir)
        set(possible_dir "${${name}_BINARY_DIR}")
      endif()
    else()
      set(possible_dir "${build_dir_config}")
    endif()
  endif()

  string(TIMESTAMP current_year "%Y" UTC)
  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/cpm.cmake.in"
                 "${CMAKE_BINARY_DIR}/rapids-cmake/${export_set}/${type}/cpm_${name}.cmake" @ONLY)

  if(NOT TARGET rapids_export_${type}_${export_set})
    add_library(rapids_export_${type}_${export_set} INTERFACE)
  endif()

  # Record that we need CPM injected into the export set
  set_property(TARGET rapids_export_${type}_${export_set} PROPERTY "REQUIRES_CPM" TRUE)

  # Need to record the <PackageName> to `rapids_export_${type}_${export_set}`
  set_property(TARGET rapids_export_${type}_${export_set} APPEND PROPERTY "PACKAGE_NAMES" "${name}")

  if(_RAPIDS_GLOBAL_TARGETS)
    # record our targets that need to be marked as global when imported
    set_property(TARGET rapids_export_${type}_${export_set} APPEND
                 PROPERTY "GLOBAL_TARGETS" "${_RAPIDS_GLOBAL_TARGETS}")
  endif()

endfunction()
