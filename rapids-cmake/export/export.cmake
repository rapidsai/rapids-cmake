#=============================================================================
# Copyright (c) 2018-2021, NVIDIA CORPORATION.
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
rapids_export
---------------------

Generate a projects -Config.cmake module and all related information

.. versionadded:: 0.20

.. command:: rapids_export_language

  .. code-block:: cmake

    rapids_export_language( (build|install) <project_name>
        EXPORT_SET <export_set>
        [GLOBAL_TARGETS <targets...>]
        [ LANGUAGES <langs...> ]
        [ NAMESPACE <name_space> ]
        [ DOCUMENTATION <doc_variable> ]
        [ FINAL_CODE_BLOCK <code_block_variable> ]
        )

  Generate a projects -Config.cmake module and all related information
  ...

  ``project_name``
    Name of the project, to be used by consumers when using `find_package`

  ``GLOBAL_TARGETS``
    Explicitly list what targets should be made globally visibile to
    the consuming project.

  ``LANGUAGES``
    Non C or C++ languages, such as CUDA that are required by consumers
    of your package. This makes sure all consumers properly setup these
    languages correctly, critically important when consuming packages
    via `CPM`.

  ``NAMESPACE``
    Optional value to specify what namespace all targets from the
    EXPORT_SET will be placed into. When provided must match the pattern
    of `<name>::`.
    If not provided all targets will be placed in the `<project_name>::`
    namespace

    Note: When exporting with `BUILD` type, only `GLOBAL_TARGETS` will
    be placed in the namespace.

  ``DOCUMENTATION``
    Optional value of the variable that holds the documentation
    for this config file.

    Note: This requires the documentation variable instead of the contents
    so we can handle having CMake code inside the documentation

  ``FINAL_CODE_BLOCK``
    Optional value of the variable that holds a string of code that will
    be executed at the last step of this config file.

    Note: This requires the code block variable instead of the contents
    so that we can properly insert CMake code



#]=======================================================================]
function(rapids_export type project_name)
  include(GNUInstallDirs)
  include(CMakePackageConfigHelpers)

  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.export")
  string(TOLOWER ${type} type)

  set(options "")
  set(one_value EXPORT_SET NAMESPACE DOCUMENTATION FINAL_CODE_BLOCK)
  set(multi_value GLOBAL_TARGETS LANGUAGES)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT DEFINED RAPIDS_NAMESPACE)
    set(RAPIDS_NAMESPACE "${project_name}::")
  endif()

  set(RAPIDS_PROJECT_DOCUMENTATION "Generated ${project_name}-config module")
  if(NOT DEFINED RAPIDS_DOCUMENTATION)
    set(RAPIDS_PROJECT_DOCUMENTATION "${${RAPIDS_DOCUMENTATION}}")
  endif()

  if(DEFINED RAPIDS_FINAL_CODE_BLOCK)
    set(RAPIDS_PROJECT_FINAL_CODE_BLOCK "${${RAPIDS_FINAL_CODE_BLOCK}}")
  endif()

  #Write configuration and version files
  string(TOLOWER ${project_name} project_name)
  if(type STREQUAL "install")
    set(install_location "${CMAKE_INSTALL_LIBDIR}/cmake/${project_name}")
    set(scratch_dir "${PROJECT_BINARY_DIR}/rapids-cmake/${project_name}/export")

    configure_package_config_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/config.cmake.in"
                                  "${scratch_dir}/${project_name}-config.cmake"
                                  INSTALL_DESTINATION "${install_location}")

    write_basic_package_version_file("${scratch_dir}/${project_name}-config-version.cmake"
                                     COMPATIBILITY SameMinorVersion)

    install(EXPORT  ${RAPIDS_EXPORT_SET}
      FILE          ${project_name}-targets.cmake
      NAMESPACE     ${RAPIDS_NAMESPACE}
      DESTINATION   "${install_location}")


    if(TARGET rapids_export_install_${RAPIDS_EXPORT_SET})
      include("${rapids-cmake-dir}/export/write_dependencies.cmake")
      set(destination "${scratch_dir}/${project_name}-dependencies.cmake")
      rapids_export_write_dependencies(INSTALL ${RAPIDS_EXPORT_SET} "${destination}")
    endif()

    if(DEFINED RAPIDS_LANGUAGES)
      include("${rapids-cmake-dir}/export/write_language.cmake")
      foreach(lang IN LISTS RAPIDS_LANGUAGES)
        set(destination "${scratch_dir}/${project_name}-${lang}-language.cmake")
        rapids_export_write_language(INSTALL ${lang} "${destination}")
      endforeach()
    endif()

    # Install everything we have generated
    install(DIRECTORY "${scratch_dir}/" DESTINATION "${install_location}")

  else()
    set(install_location "${PROJECT_BINARY_DIR}")
    configure_package_config_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/config.cmake.in"
                                  "${install_location}/${project_name}-config.cmake"
                                  INSTALL_DESTINATION "${install_location}")

    write_basic_package_version_file("${install_location}/${project_name}-config-version.cmake"
                                     COMPATIBILITY SameMinorVersion)

    export(EXPORT ${RAPIDS_EXPORT_SET}
           FILE "${install_location}/${project_name}-targets.cmake"
           )

    if(TARGET rapids_export_build_${RAPIDS_EXPORT_SET})
      include("${rapids-cmake-dir}/export/write_dependencies.cmake")
      rapids_export_write_dependencies(BUILD ${RAPIDS_EXPORT_SET}
                                       "${install_location}/${project_name}-dependencies.cmake")
    endif()

    if(DEFINED RAPIDS_LANGUAGES)
      include("${rapids-cmake-dir}/export/write_language.cmake")
      foreach(lang IN LISTS RAPIDS_LANGUAGES)
        rapids_export_write_language(BUILD ${lang} "${install_location}/${project_name}-${lang}-language.cmake")
      endforeach()
    endif()

  endif()

endfunction()
