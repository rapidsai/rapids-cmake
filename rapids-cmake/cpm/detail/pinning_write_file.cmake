#=============================================================================
# Copyright (c) 2024-2025, NVIDIA CORPORATION.
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
rapids_cpm_pinning_extract_source_git_info
------------------------------------------

.. versionadded:: v24.04.00

Extract the git url and git sha1 from the source directory of
the given package.

Parameters:

``package``
    Name of package to extract git url and git sha for

``git_url_var``
    Holds the name of the variable to set in the calling scope with the
    git url extracted from the package.

    If no git url can be found for the package, the variable won't be set.

``git_sha_var``
    Holds the name of the variable to set in the calling scope with the
    git sha1 extracted from the package.

    If no git sha1 can be found for the package, the variable won't be set.

#]=======================================================================]
function(rapids_cpm_pinning_extract_source_git_info package git_url_var git_sha_var)
  cmake_parse_arguments(_RAPIDS "" "REQUESTED_GIT_TAG" "" ${ARGN})

  set(source_dir "${CPM_PACKAGE_${package}_SOURCE_DIR}")
  set(_RAPIDS_URL)
  set(_RAPIDS_SHA)
  if(EXISTS "${source_dir}")
    execute_process(COMMAND ${GIT_EXECUTABLE} ls-remote --get-url
                    WORKING_DIRECTORY ${source_dir}
                    ERROR_QUIET
                    OUTPUT_VARIABLE _RAPIDS_URL
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    # Need to handle when we have applied N patch sets to the git repo and therefore the latest
    # commit is just local
    #
    # Find all commits on our branch back to the common parent ( what we cloned )
    #
    execute_process(COMMAND ${GIT_EXECUTABLE} show-branch --current --sha1-name
                            ${_RAPIDS_REQUESTED_GIT_TAG}
                    WORKING_DIRECTORY ${source_dir}
                    ERROR_QUIET
                    OUTPUT_VARIABLE _rapids_commit_stack
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    # The last entry in the output that has "* [" is our commit
    #
    # Find that line and convert the `* [short-sha1] Commit Message` to a list that is ` *
    # ;short-sha1;Commit Message` and extract the short sha1
    string(FIND "${_rapids_commit_stack}" "* [" position REVERSE)
    if(position LESS 0)
      # No changes to the repo so use the `HEAD` keyword
      set(short_sha HEAD)
    else()
      string(SUBSTRING "${_rapids_commit_stack}" ${position} -1 _rapids_commit_stack)
      string(REGEX REPLACE "(\\[|\\])" ";" _rapids_commit_stack "${_rapids_commit_stack}")
      list(GET _rapids_commit_stack 1 short_sha)
    endif()

    # Convert from the short sha1 ( could be keyword `HEAD` ) to a full SHA1
    execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse ${short_sha}
                    WORKING_DIRECTORY ${source_dir}
                    ERROR_QUIET
                    OUTPUT_VARIABLE _RAPIDS_SHA
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
  endif()
  # Only set the provided variables if we extracted the information
  if(_RAPIDS_URL)
    set(${git_url_var} "${_RAPIDS_URL}" PARENT_SCOPE)
  endif()
  if(_RAPIDS_SHA)
    set(${git_sha_var} "${_RAPIDS_SHA}" PARENT_SCOPE)
  endif()

endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_transform_patches
------------------------------------

.. versionadded:: v25.02.00

Transform the `patches` value json string to not reference any files
on disk but instead embed the patches contents directly in the json

Parameters:

``value_var``
    Variable name of the json object of the patch content to transform

#]=======================================================================]
function(rapids_cpm_pinning_transform_patches package_name patches_array_var output_var)

  include("${rapids-cmake-dir}/cpm/detail/convert_patch_json.cmake")

  # We need to get the `files` key and transform it
  set(json_data "${${patches_array_var}}")
  string(JSON patch_count LENGTH "${json_data}")
  if(patch_count GREATER_EQUAL 1)

    # Setup state so that we can eval `current_json_dir` placeholder
    string(TOLOWER "${package_name}" normalized_pkg_name)
    get_property(json_path GLOBAL PROPERTY rapids_cpm_${normalized_pkg_name}_override_json_file)
    if(NOT json_path)
      get_property(json_path GLOBAL PROPERTY rapids_cpm_${normalized_pkg_name}_json_file)
    endif()
    cmake_path(GET json_path PARENT_PATH current_json_dir)

    math(EXPR patch_count "${patch_count} - 1")
    # cmake-lint: disable=E1120
    foreach(index RANGE ${patch_count})
      string(JSON patch_data GET "${json_data}" ${index})
      string(JSON file_path ERROR_VARIABLE have_error GET "${patch_data}" file)
      cmake_language(EVAL CODE "set(file_path ${file_path})")
      if(file_path)
        # Eval the file to transform `current_json_dir`
        cmake_path(IS_RELATIVE file_path is_relative)
        if(is_relative)
          string(PREPEND file_path "${rapids-cmake-dir}/cpm/patches/")
        endif()

        # Read the file and transform to string
        rapids_cpm_convert_patch_json(FROM_FILE_TO_JSON as_json FILE_VAR file_path)
        # Remove the the file entry and replace it with the correct inline json format
        string(JSON patch_data ERROR_VARIABLE have_error REMOVE "${patch_data}" file)
        set(json_key "inline_patch")
        string(JSON patch_data ERROR_VARIABLE have_error SET "${patch_data}" "${json_key}"
               "${as_json}")
        string(JSON json_data SET "${json_data}" ${index} "${patch_data}")
      endif()
    endforeach()
  endif()
  set(${output_var} "${json_data}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_create_and_set_member
----------------------------------------

.. versionadded:: v24.04.00

Insert the given json key value pair into the provided json object variable.
If the key already exists in the json object, this will overwrite with the
new value.

Parameters:

``package_name``
    Name of the project that this json object is associated to.

``json_var``
    Variable name of the json object to both read and write too.

``key``
    Holds the key that should be created/updated in the json object
``var``
    Holds the var that should be written to the json object

#]=======================================================================]
function(rapids_cpm_pinning_create_and_set_member package_name json_var key value)

  if(key MATCHES "patches")
    # Transform inplace the value to only have inline patches
    rapids_cpm_pinning_transform_patches(${package_name} value value)
  endif()
  # Identify special values types that shouldn't be treated as a string
  # https://gitlab.kitware.com/cmake/cmake/-/issues/25716
  if(value MATCHES "(^true$|^false$|^null$|^\\{|^\\[)")
    # value is a json type that doesn't need quotes
    string(JSON json_blob ERROR_VARIABLE err_var SET "${${json_var}}" ${key} ${value})
  else()
    # We need to quote 'value' so that it is a valid string json element.
    string(JSON json_blob ERROR_VARIABLE err_var SET "${${json_var}}" ${key} "\"${value}\"")
  endif()
  set(${json_var} "${json_blob}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_add_json_entry
---------------------------------

.. versionadded:: v24.04.00

Write a valid json object that represent the package with the updated
If the key already exists in the json object, this will overwrite with the
new value.

The generated json object will have `git_shallow` as `false`, and
`always_download` as `true`. This ensures we always build from source, and
that we can safely fetch even when the SHA1 doesn't reference the tip of a named
branch/tag.

Parameters:

``package``
    Name of package to generate a valid json object for.

``json_var``
    Variable name to write the generated json object to in the callers
    scope.

#]=======================================================================]
function(rapids_cpm_pinning_add_json_entry package_name json_var)

  # Make sure variables from the callers scope doesn't break us
  unset(git_url)
  unset(git_sha)
  unset(url_string)
  unset(sha_string)

  include("${rapids-cmake-dir}/cpm/detail/get_default_json.cmake")
  include("${rapids-cmake-dir}/cpm/detail/get_override_json.cmake")
  get_default_json(${package_name} json_data)
  get_override_json(${package_name} override_json_data)

  set(baseline_arg)
  string(JSON value ERROR_VARIABLE have_error GET "${override_json_data}" git_tag)
  if(have_error)
    string(JSON value ERROR_VARIABLE have_error GET "${json_data}" git_tag)
  endif()
  if(NOT have_error)
    set(baseline_arg REQUESTED_GIT_TAG "${value}")
  endif()

  rapids_cpm_pinning_extract_source_git_info(${package} git_url git_sha ${baseline_arg})
  if(git_url)
    string(CONFIGURE [=["git_url": "${git_url}",]=] url_string)
  endif()
  if(git_sha)
    string(CONFIGURE [=["git_tag": "${git_sha}",]=] sha_string)
  endif()
  # We start with a default template, and only add members that don't exist
  string(CONFIGURE [=[{
  "version": "${CPM_PACKAGE_${package_name}_VERSION}",
  ${url_string}
  ${sha_string}
  "git_shallow": false,
  "always_download": true
  }]=]
                   pinned_json_entry)

  set(override_exclusion_list "")
  set(json_exclusion_list "")
  # patch and proprietary_binary can't propagate if an override exists
  if(override_json_data)
    list(APPEND json_exclusion_list "patch" "proprietary_binary")
  endif()

  set(data_list override_json_data json_data)
  set(exclusion_list override_exclusion_list json_exclusion_list)
  foreach(data_var exclusion_var IN ZIP_LISTS data_list exclusion_list)
    set(data "${${data_var}}")
    set(exclusions "${${exclusion_var}}")
    if(NOT data)
      # Need to handle both json_data and the override being empty
      continue()
    endif()
    string(JSON entry_count LENGTH "${data}")
    math(EXPR entry_count "${entry_count} - 1")
    # cmake-lint: disable=E1120
    foreach(index RANGE ${entry_count})
      string(JSON member MEMBER "${data}" ${index})
      string(JSON existing_value ERROR_VARIABLE dont_have GET "${pinned_json_entry}" ${member})
      if(dont_have AND (NOT member IN_LIST exclusions))
        string(JSON value GET "${data}" ${member})
        rapids_cpm_pinning_create_and_set_member(${package_name} pinned_json_entry ${member}
                                                 ${value})
      endif()
    endforeach()
  endforeach()
  set(${json_var} "\"${package_name}\": ${pinned_json_entry}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_write_file
-----------------------------

.. versionadded:: v24.04.00

This function generates a rapids-cmake `versions.json` file that has
pinned versions of each project that resolved to an CPMAddPackage call for
this CMake project.

This pinned versions.json file will be written to all output files
provided to :cmake:command:`rapids_cpm_generate_pinned_versions`.
#]=======================================================================]
function(rapids_cpm_pinning_write_file)

  find_package(Git QUIET REQUIRED)

  set(_rapids_json
      [=[
{
"root": {
"packages": {
]=])

  # initial pass to remove any packages that aren't checked out by source or an existing json entry.
  #
  # By doing this as an initial pass it makes the logic around `last_package` and trailing comma's
  # significantly easier
  set(packages)
  set(ignored_packages)
  foreach(package IN LISTS CPM_PACKAGES)
    # Only add packages that have a src tree, that way we exclude packages that have been found
    # locally via `CPMFindPackage`
    if(NOT DEFINED CPM_PACKAGE_${package}_SOURCE_DIR)
      # check to see if we have an rapids_cmake json entry, this catches all packages like nvcomp
      # that don't have a source tree.
      include("${rapids-cmake-dir}/cpm/detail/get_default_json.cmake")
      include("${rapids-cmake-dir}/cpm/detail/get_override_json.cmake")
      get_default_json(${package} json_data)
      get_override_json(${package} override_json_data)
      if(NOT (json_data OR override_json_data))
        list(APPEND ignored_packages ${package})
        continue()
      endif()
    endif()
    list(APPEND packages ${package})
  endforeach()

  list(POP_BACK packages last_package)
  foreach(package IN LISTS packages last_package)
    # Clear variables so we don't re-use them between packages when one package doesn't have a git
    # url or sha
    set(git_url)
    set(git_sha)
    set(not_last_package TRUE)
    if(package STREQUAL last_package)
      set(not_last_package FALSE)
    endif()
    rapids_cpm_pinning_add_json_entry(${package} _rapids_entry)
    if(not_last_package)
      string(APPEND _rapids_entry [=[,
]=])
    else()
      string(APPEND _rapids_entry [=[
]=])
    endif()
    string(APPEND _rapids_json "${_rapids_entry}")
  endforeach()

  # Add closing braces
  string(APPEND _rapids_json [=[}}}]=])

  # We extract everything out of the fake `root` element so that we get a pretty JSON format from
  # CMake.
  string(JSON _rapids_json GET "${_rapids_json}" root)

  get_property(write_paths GLOBAL PROPERTY rapids_cpm_generate_pin_files)
  foreach(path IN LISTS write_paths)
    file(WRITE "${path}" "${_rapids_json}")
  endforeach()

  # Setup status string to developer.
  set(message_extra_info)
  if(ignored_packages)
    set(message_extra_info
        "The following packages resolved to system installed versions: ${ignored_packages}. If you need those pinned to an explicit version please set `CPM_DOWNLOAD_ALL` and re-generate."
    )
  endif()

  message(STATUS "rapids_cpm_generate_pinned_versions wrote version information. ${message_extra_info}"
  )
endfunction()
