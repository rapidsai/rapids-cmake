# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cmake_default_install_component
---------------------------------------

.. versionadded:: v26.08.00

Sets up component install names for a package dependency managed by `rapids_cpm`.

  .. code-block:: cmake

    rapids_cmake_default_install_component(DEFAULT_USE_PROJECT_NAME)
    rapids_cmake_default_install_component(PROJECT <project_name> INSTALL_COMPONENT_NAME <component_name>)

The `DEFAULT_USE_PROJECT_NAME` option will set the default install component name to the project name or
one may set a custom install component name `component_name` for a given project `project_name`.

``DEFAULT_USE_PROJECT_NAME``
  Enables the use of project name as the default install component name.

``PROJECT``
  The project name to set a custom install component name for.

``INSTALL_COMPONENT_NAME``
  The install component name to set for a given project.

#]=======================================================================]
function(rapids_cmake_default_install_component)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.default_install_component")
  set(options DEFAULT_USE_PROJECT_NAME)
  set(one_value PROJECT INSTALL_COMPONENT_NAME)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  # Need to make sure we only install our project hook once
  get_property(already_hooked GLOBAL PROPERTY rapids_cmake_default_install_component_hook)
  if(NOT already_hooked)
    list(APPEND CMAKE_PROJECT_INCLUDE
         "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/default_install_component_hook.cmake")
    set(CMAKE_PROJECT_INCLUDE "${CMAKE_PROJECT_INCLUDE}" PARENT_SCOPE)

    set_property(GLOBAL PROPERTY rapids_cmake_default_install_component_hook ON)
  endif()

  if(_RAPIDS_DEFAULT_USE_PROJECT_NAME)
    set_property(GLOBAL PROPERTY rapids_cmake_default_install_component_names ON)
  endif()
  if(_RAPIDS_PROJECT AND _RAPIDS_INSTALL_COMPONENT_NAME)
    # Should only be set if the property doesn't already exist
    string(TOLOWER ${_RAPIDS_PROJECT} project)
    set_property(GLOBAL PROPERTY rapids_cmake_install_component_${project}
                                 ${_RAPIDS_INSTALL_COMPONENT_NAME})
  endif()
endfunction()
