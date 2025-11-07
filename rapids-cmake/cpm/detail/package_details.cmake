# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cpm_package_details
--------------------------

. code-block:: cmake

  rapids_cpm_package_details(<package_name>
                             <version_variable>
                             <git_url_variable>
                             <git_tag_variable>
                             <shallow_variable>
                             <exclude_from_all_variable>
                             )

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`rapids_cmake_always_download` will contain the value of the `always_download` entry if it exists.
  :cmake:variable:`CPM_DOWNLOAD_ALL` will contain the value of the `always_download` entry if it exists.

#]=======================================================================]
# cmake-lint: disable=R0913
function(rapids_cpm_package_details package_name version_var url_var tag_var shallow_var
         exclude_from_all_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_cpm_package_details")

  include("${rapids-cmake-dir}/cmake/detail/policy.cmake")
  rapids_cmake_policy(DEPRECATED_IN 25.10
                      REMOVED_IN 26.02
                      MESSAGE [=[`rapids_cpm_package_details` is deprecated. Please use `rapids_cpm_package_info` instead.]=]
  )

  rapids_cpm_package_details_internal(${package_name} ${version_var} ${url_var} ${tag_var}
                                      src_subdir ${shallow_var} ${exclude_from_all_var})
  set(${version_var} ${${version_var}} PARENT_SCOPE)
  set(${url_var} ${${url_var}} PARENT_SCOPE)
  set(${tag_var} ${${tag_var}} PARENT_SCOPE)
  set(${shallow_var} ${${shallow_var}} PARENT_SCOPE)
  set(${exclude_from_all_var} ${${exclude_from_all_var}} PARENT_SCOPE)
  if(DEFINED rapids_cmake_always_download)
    set(rapids_cmake_always_download ${rapids_cmake_always_download} PARENT_SCOPE)
    set(CPM_DOWNLOAD_ALL ${CPM_DOWNLOAD_ALL} PARENT_SCOPE)
  endif()

endfunction()

# cmake-lint: disable=R0913,R0915
function(rapids_cpm_package_details_internal package_name version_var url_var tag_var subdir_var
         shallow_var exclude_from_all_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.rapids_cpm_package_details_internal")

  include("${rapids-cmake-dir}/cpm/detail/load_preset_versions.cmake")
  rapids_cpm_load_preset_versions()

  include("${rapids-cmake-dir}/cpm/detail/get_default_json.cmake")
  include("${rapids-cmake-dir}/cpm/detail/get_override_json.cmake")
  get_default_json(${package_name} json_data)
  get_override_json(${package_name} override_json_data)

  # Parse required fields
  function(rapids_cpm_json_get_value name)
    string(JSON value ERROR_VARIABLE have_error GET "${override_json_data}" ${name})
    if(have_error)
      string(JSON value ERROR_VARIABLE have_error GET "${json_data}" ${name})
    endif()

    if(NOT have_error)
      set(${name} ${value} PARENT_SCOPE)
    endif()
  endfunction()

  rapids_cpm_json_get_value(version)
  rapids_cpm_json_get_value(git_url)
  rapids_cpm_json_get_value(git_tag)

  # Only do validation if we have an entry
  if(json_data OR override_json_data)
    # Validate that we have the required fields
    foreach(var IN ITEMS version git_url git_tag)
      if(NOT ${var})
        message(FATAL_ERROR "rapids_cmake can't parse '${package_name}' json entry, it is missing a `${var}` entry"
        )
      endif()
    endforeach()
  endif()

  if(override_json_data)
    string(JSON value ERROR_VARIABLE no_url_override GET "${override_json_data}" git_url)
    string(JSON value ERROR_VARIABLE no_tag_override GET "${override_json_data}" git_tag)
    string(JSON value ERROR_VARIABLE no_patches_override GET "${override_json_data}" patches)
    set(git_details_overridden TRUE)
    if(no_url_override AND no_tag_override AND no_patches_override)
      set(git_details_overridden FALSE)
    endif()
  endif()

  # Parse optional fields, set the variable to the 'default' value first
  set(git_shallow ON)
  rapids_cpm_json_get_value(git_shallow)

  unset(source_subdir)
  rapids_cpm_json_get_value(source_subdir)

  set(exclude_from_all OFF)
  rapids_cpm_json_get_value(exclude_from_all)

  # Ensure that always_download is not set by default so that the if(DEFINED always_download) check
  # below works as expected in the default case.
  unset(always_download)
  unset(override_ignored)
  if(override_json_data AND json_data AND git_details_overridden)
    # `always_download` default value requires the package to exist in both the default and override
    # and that the git url / git tag have been modified. We also need to make sure that when using
    # an override that it isn't disabled due to `CPM_<pkg>_SOURCE`
    string(TOLOWER "${package_name}" normalized_pkg_name)
    get_property(override_ignored GLOBAL
                 PROPERTY rapids_cpm_${normalized_pkg_name}_override_ignored)
    if(NOT (override_ignored OR DEFINED CPM_${package_name}_SOURCE))
      set(always_download ON)
    endif()
  endif()
  rapids_cpm_json_get_value(always_download)

  # Evaluate any magic placeholders in the version or tag components including the
  # `rapids-cmake-version` and `rapids-cmake-checkout-tag` values
  include("${rapids-cmake-dir}/rapids-version.cmake")

  cmake_language(EVAL CODE "set(version ${version})")
  cmake_language(EVAL CODE "set(git_tag ${git_tag})")
  cmake_language(EVAL CODE "set(git_url ${git_url})")

  set(${version_var} ${version} PARENT_SCOPE)
  set(${url_var} ${git_url} PARENT_SCOPE)
  set(${tag_var} ${git_tag} PARENT_SCOPE)
  set(${shallow_var} ${git_shallow} PARENT_SCOPE)
  set(${exclude_from_all_var} ${exclude_from_all} PARENT_SCOPE)
  if(DEFINED source_subdir)
    set(${subdir_var} ${source_subdir} PARENT_SCOPE)
  endif()
  if(DEFINED always_download)
    set(rapids_cmake_always_download ${always_download} PARENT_SCOPE)
    set(CPM_DOWNLOAD_ALL ${always_download} PARENT_SCOPE)
  endif()

endfunction()
