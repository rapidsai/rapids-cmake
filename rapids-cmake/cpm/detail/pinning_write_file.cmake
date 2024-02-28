#=============================================================================
# Copyright (c) 2024, NVIDIA CORPORATION.
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


#]=======================================================================]
function(rapids_cpm_pinning_extract_source_git_info package git_url_var git_sha_var)
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
rapids_cpm_pinning_create_and_set_member
----------------------------------------

.. versionadded:: v24.04.00

Insert the given json key value pair into the provided json data variable

#]=======================================================================]
function(rapids_cpm_pinning_create_and_set_member json_blob_var key value)

  # Identify special values types that shouldn't be treated as a string
  # https://gitlab.kitware.com/cmake/cmake/-/issues/25716
  if(value MATCHES "(^true$|^false$|^null$|^\\{|^\\[)")
    # value is a json type that doesn't need quotes
    string(JSON json_blob ERROR_VARIABLE err_var SET "${${json_blob_var}}" ${key} ${value})
  else()
    # We need to quote 'value' so that it is a valid string json element.
    string(JSON json_blob ERROR_VARIABLE err_var SET "${${json_blob_var}}" ${key} "\"${value}\"")
  endif()
  set(${json_blob_var} "${json_blob}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_add_json_entry
---------------------------------

.. versionadded:: v24.04.00

#]=======================================================================]
function(rapids_cpm_pinning_add_json_entry json_var package_name url_var sha_var)
  include("${rapids-cmake-dir}/cpm/detail/get_default_json.cmake")
  include("${rapids-cmake-dir}/cpm/detail/get_override_json.cmake")
  get_default_json(${package_name} json_data)
  get_override_json(${package_name} override_json_data)

  set(url_string)
  set(sha_string)
  if(${url_var})
    string(CONFIGURE [=["git_url": "${${url_var}}",]=] url_string)
  endif()
  if(${sha_var})
    string(CONFIGURE [=["git_tag": "${${sha_var}}",]=] sha_string)
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

  foreach(data IN LISTS override_json_data json_data)
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
      if(dont_have)
        string(JSON value GET "${data}" ${member})
        rapids_cpm_pinning_create_and_set_member(pinned_json_entry ${member} ${value})
      endif()
    endforeach()
  endforeach()
  set(${json_var} "\"${package_name}\": ${pinned_json_entry}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_pretty_format_json
-------------------------------------


.. versionadded:: v24.04.00

Formats provided JSON to be easily read by humans
#]=======================================================================]
function(rapids_cpm_pinning_pretty_format_json _rapids_json_var)
  set(pretty_json)
  #[=[
  - parse each line
  - trim all leading spaces
  - exclusive if line contains "}" or "]" decement indenter
  - print with given indenter
  - exclusive if line contains "{" or "[" increment indenter
  ]=]
  #
  set(indent "  ")
  set(indent_len 2)
  set(current_indent "")
  string(REPLACE "\n" ";" input "${${_rapids_json_var}}")

  # Needed due to rules around cmake language list expansion:
  #
  # during evaluation of an Unquoted Argument. In such contexts, a string is divided into list
  # elements by splitting on ; characters not following an unequal number of [ and ] characters
  #
  string(REPLACE "[" "``" input "${input}")
  string(REPLACE "]" "~~" input "${input}")
  foreach(line ${input})
    string(STRIP "${line}" line)
    set(push_indent)
    set(pop_indent)
    if(line MATCHES "(\\{|``)")
      set(push_indent TRUE)
    endif()
    if(line MATCHES "(\\}|~~)")
      set(pop_indent TRUE)
    endif()

    if(pop_indent AND NOT push_indent)
      string(SUBSTRING "${current_indent}" ${indent_len} -1 current_indent)
    endif()

    string(APPEND pretty_json "${current_indent}${line}\n")

    if(push_indent AND NOT pop_indent)
      string(APPEND current_indent "${indent}")
    endif()
  endforeach()
  string(REPLACE "``" "[" pretty_json "${pretty_json}")
  string(REPLACE "~~" "]" pretty_json "${pretty_json}")
  set(${_rapids_json_var} "${pretty_json}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
rapids_cpm_pinning_write_file
-----------------------------

.. versionadded:: v24.04.00

This function will write out the pinned version info to the provided files when we are in the root
CMakeLists.txt
#]=======================================================================]
function(rapids_cpm_pinning_write_file)

  find_package(Git QUIET REQUIRED)

  set(_rapids_json
      [=[
{
"packages": {
]=])

  list(POP_BACK CPM_PACKAGES last_package)
  foreach(package IN LISTS CPM_PACKAGES last_package)
    # Clear variables so we don't re-use them between packages when one package doesn't have a git
    # url or sha
    set(git_url)
    set(git_sha)
    set(not_last_package TRUE)
    if(package STREQUAL last_package)
      set(not_last_package FALSE)
    endif()
    rapids_cpm_pinning_extract_source_git_info(${package} git_url git_sha)
    rapids_cpm_pinning_add_json_entry(_rapids_entry ${package} git_url git_sha)
    if(not_last_package)
      string(APPEND _rapids_entry [=[,
]=])
    else()
      string(APPEND _rapids_entry [=[
]=])
    endif()
    string(APPEND _rapids_json "${_rapids_entry}")
  endforeach()

  set(post_amble
      [=[
}
}]=])
  string(APPEND _rapids_json "${post_amble}")

  rapids_cpm_pinning_pretty_format_json(_rapids_json)

  get_property(write_paths GLOBAL PROPERTY rapids_cpm_generate_pin_files)
  foreach(path IN LISTS write_paths)
    file(WRITE "${path}" "${_rapids_json}")
  endforeach()

endfunction()
