# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cpm_nvcomp
-----------------
.. versionadded:: v22.06.00

Allow projects to find or build `nvCOMP` via `CPM` with built-in
tracking of these dependencies for correct export support.

Uses the version of nvCOMP :ref:`specified in the version file <cpm_versions>` for consistency
across all RAPIDS projects.

.. code-block:: cmake

  rapids_cpm_nvcomp( USE_PROPRIETARY_BINARY <ON|OFF>
                     [BUILD_EXPORT_SET <export-name>]
                     [INSTALL_EXPORT_SET <export-name>]
                     [<CPM_ARGS> ...])

``USE_PROPRIETARY_BINARY``
  By enabling this flag and using the software, you agree to fully comply with the terms and conditions of
  nvCOMP's NVIDIA Software License Agreement, found at https://developer.download.nvidia.com/compute/nvcomp/2.3/LICENSE.txt.

  nvCOMP is distributed as a pre-built proprietary binary. This flag is required for rapids-cmake to
  download nvCOMP; without it, nvCOMP can only be found if already installed on the system.

.. note::
  If an override entry exists for the nvCOMP package it MUST have a ``proprietary_binary`` entry for this
  flag to do anything. Any override without this entry is considered to invalidate the existing proprietary
  binary entry.

.. |PKG_NAME| replace:: nvcomp
.. include:: common_package_args.txt

Result Targets
^^^^^^^^^^^^^^
  nvcomp::nvcomp target will be created
  nvcomp::nvcomp_cpu target will be created
  nvcomp::nvcomp_static target might be created
  nvcomp::nvcomp_cpu_static target might be created

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`nvcomp_SOURCE_DIR` is set to the path to the source directory of nvCOMP.
  :cmake:variable:`nvcomp_BINARY_DIR` is set to the path to the build directory of nvCOMP.
  :cmake:variable:`nvcomp_ADDED`      is set to a true value if nvCOMP has not been added before.
  :cmake:variable:`nvcomp_VERSION`    is set to the version of nvCOMP specified by the versions.json.
  :cmake:variable:`nvcomp_proprietary_binary` is set to ON if the proprietary binary is being used

#]=======================================================================]
# cmake-lint: disable=R0915,R0912
function(rapids_cpm_nvcomp)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.nvcomp")

  set(options)
  set(one_value USE_PROPRIETARY_BINARY)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT _RAPIDS_USE_PROPRIETARY_BINARY)
    message(WARNING "rapids_cpm_nvcomp called without USE_PROPRIETARY_BINARY ON. nvcomp can only be found if already installed on the system."
    )
  endif()

  include("${rapids-cmake-dir}/cpm/detail/package_info.cmake")
  rapids_cpm_package_info(nvcomp ${_RAPIDS_UNPARSED_ARGUMENTS} VERSION_VAR version FIND_VAR
                          find_args CPM_VAR cpm_find_info TO_INSTALL_VAR to_install)

  # First search locally if `rapids_cmake_always_download` is false
  if(NOT rapids_cmake_always_download)
    include("${rapids-cmake-dir}/find/package.cmake")
    rapids_find_package(nvcomp ${version} GLOBAL_TARGETS nvcomp::nvcomp ${_RAPIDS_EXPORT_ARGUMENTS}
                        FIND_ARGS QUIET)
    if(nvcomp_FOUND)
      # Report where nvcomp was found
      message(STATUS "Found nvcomp: ${nvcomp_DIR} (found version ${nvcomp_VERSION})")
    endif()
  endif()

  # Set up the version of nvcomp we have downloaded to match the OS layout. That means ensuring we
  # have a `lib64` directory on Fedora based machines
  include("${rapids-cmake-dir}/cmake/install_lib_dir.cmake")
  rapids_cmake_install_lib_dir(lib_dir)

  # Second see if we have a proprietary pre-built binary listed in versions.json and download it if
  # requested.
  set(nvcomp_proprietary_binary OFF) # will be set to true by rapids_cpm_get_proprietary_binary
  if(_RAPIDS_USE_PROPRIETARY_BINARY AND NOT nvcomp_FOUND)
    include("${rapids-cmake-dir}/cpm/detail/get_proprietary_binary_url.cmake")
    include("${rapids-cmake-dir}/cpm/detail/download_proprietary_binary.cmake")
    rapids_cpm_get_proprietary_binary_url(nvcomp ${version} nvcomp_url)
    if(nvcomp_url)
      rapids_cpm_download_proprietary_binary(nvcomp ${nvcomp_url})
    endif()

    if(nvcomp_proprietary_binary)
      if(NOT EXISTS "${nvcomp_ROOT}/${lib_dir}/cmake/nvcomp/nvcomp-config.cmake")
        include(GNUInstallDirs)
        cmake_path(GET lib_dir PARENT_PATH lib_dir_parent)
        cmake_path(GET CMAKE_INSTALL_INCLUDEDIR PARENT_PATH include_dir_parent)
        if(NOT lib_dir_parent STREQUAL include_dir_parent)
          message(FATAL_ERROR "CMAKE_INSTALL_INCLUDEDIR and CMAKE_INSTALL_LIBDIR must share parent directory"
          )
        endif()

        # Replace ${_IMPORT_PREFIX}/lib/ with ${_IMPORT_PREFIX}/${lib_dir}/ in
        # nvcomp-release-targets.cmake. Guarded in an EXISTS check so we only try to do this on the
        # first configuration pass
        cmake_path(GET lib_dir FILENAME lib_dir_name)
        set(nvcomp_list_of_target_files
            "nvcomp-targets-common-release.cmake"
            "nvcomp-targets-common.cmake"
            "nvcomp-targets-dynamic-release.cmake"
            "nvcomp-targets-dynamic.cmake"
            "nvcomp-targets-release.cmake"
            "nvcomp-targets-static-release.cmake"
            "nvcomp-targets-static.cmake")
        foreach(filename IN LISTS nvcomp_list_of_target_files)
          if(EXISTS "${nvcomp_ROOT}/lib/cmake/nvcomp/${filename}")
            file(READ "${nvcomp_ROOT}/lib/cmake/nvcomp/${filename}" FILE_CONTENTS)
            string(REPLACE "\$\{_IMPORT_PREFIX\}/lib/" "\$\{_IMPORT_PREFIX\}/${lib_dir_name}/"
                           FILE_CONTENTS ${FILE_CONTENTS})
            file(WRITE "${nvcomp_ROOT}/lib/cmake/nvcomp/${filename}" ${FILE_CONTENTS})
          endif()
        endforeach()
        file(MAKE_DIRECTORY "${nvcomp_ROOT}/${lib_dir_parent}")
        file(RENAME "${nvcomp_ROOT}/lib/" "${nvcomp_ROOT}/${lib_dir}/")
        # Move the `include` dir if necessary as well
        file(RENAME "${nvcomp_ROOT}/include/" "${nvcomp_ROOT}/${CMAKE_INSTALL_INCLUDEDIR}/")
      endif()

      # Record the nvcomp_DIR so that if USE_PROPRIETARY_BINARY is disabled we can safely clear the
      # nvcomp_DIR value
      set(nvcomp_proprietary_root "${nvcomp_ROOT}")
      cmake_path(NORMAL_PATH nvcomp_proprietary_root)
      set(rapids_cpm_nvcomp_proprietary_root "${nvcomp_proprietary_root}"
          CACHE INTERNAL "nvcomp proprietary root dir location")

      # Enforce that we need to find the local download of nvcomp and nothing else when we have a
      # proprietary binary enabled.
      list(APPEND CMAKE_PREFIX_PATH "${nvcomp_ROOT}/${lib_dir}/cmake/nvcomp")
      unset(CPM_DOWNLOAD_ALL)
      set(CPM_USE_LOCAL_PACKAGES ON)
    endif()
  elseif(DEFINED nvcomp_DIR)
    cmake_path(NORMAL_PATH nvcomp_DIR)
    if(nvcomp_DIR STREQUAL "${rapids_cpm_nvcomp_proprietary_root}/${lib_dir}/cmake/nvcomp")
      set(nvcomp_proprietary_binary ON)
      set(nvcomp_ROOT "${rapids_cpm_nvcomp_proprietary_root}")
      unset(nvcomp_DIR)
      unset(nvcomp_DIR CACHE)
    endif()
  endif()

  include("${rapids-cmake-dir}/cpm/find.cmake")
  rapids_cpm_find(nvcomp ${version} ${find_args} GLOBAL_TARGETS nvcomp::nvcomp
                  CPM_ARGS ${cpm_find_info} OPTIONS "BUILD_STATIC ON" "BUILD_TESTS OFF"
                                                    "BUILD_BENCHMARKS OFF" "BUILD_EXAMPLES OFF")

  include("${rapids-cmake-dir}/cpm/detail/display_patch_status.cmake")
  rapids_cpm_display_patch_status(nvcomp)

  # Provide consistent targets between a found nvcomp and one building from source
  set(nvcomp_possible_target_names nvcomp nvcomp_cpu nvcomp_cpu_static nvcomp_static)
  foreach(name IN LISTS nvcomp_possible_target_names)
    if(NOT TARGET nvcomp::${name} AND TARGET ${name})
      add_library(nvcomp::${name} ALIAS ${name})
    endif()
  endforeach()

  # Propagate up variables that CPMFindPackage provide
  set(nvcomp_SOURCE_DIR "${nvcomp_SOURCE_DIR}" PARENT_SCOPE)
  set(nvcomp_BINARY_DIR "${nvcomp_BINARY_DIR}" PARENT_SCOPE)
  set(nvcomp_ADDED "${nvcomp_ADDED}" PARENT_SCOPE)
  set(nvcomp_VERSION ${version} PARENT_SCOPE)
  set(nvcomp_proprietary_binary ${nvcomp_proprietary_binary} PARENT_SCOPE)

  # Set up up install rules when using the proprietary_binary. When building from source, nvcomp
  # will set the correct install rules
  if(to_install AND nvcomp_proprietary_binary)
    include("${rapids-cmake-dir}/cmake/install_lib_dir.cmake")
    rapids_cmake_install_lib_dir(lib_dir)
    include(GNUInstallDirs)

    install(DIRECTORY "${nvcomp_ROOT}/${lib_dir}/" DESTINATION "${lib_dir}")
    install(DIRECTORY "${nvcomp_ROOT}/${CMAKE_INSTALL_INCLUDEDIR}/"
            DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
    if(EXISTS "${nvcomp_ROOT}/${CMAKE_INSTALL_BINDIR}")
      install(DIRECTORY "${nvcomp_ROOT}/${CMAKE_INSTALL_BINDIR}/"
              DESTINATION "${CMAKE_INSTALL_BINDIR}")
    endif()
    # Place the license information in the location that conda uses
    install(FILES "${nvcomp_ROOT}/NOTICE" DESTINATION info/ RENAME NVCOMP_NOTICE)
    install(FILES "${nvcomp_ROOT}/LICENSE" DESTINATION info/ RENAME NVCOMP_LICENSE)
  endif()

  # Point our consumers to where they can find the pre-built version
  include("${rapids-cmake-dir}/export/find_package_root.cmake")
  rapids_export_find_package_root(BUILD nvcomp "${nvcomp_ROOT}"
                                  EXPORT_SET ${_RAPIDS_BUILD_EXPORT_SET}
                                  CONDITION nvcomp_proprietary_binary)

endfunction()
