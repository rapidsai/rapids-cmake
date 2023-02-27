#=============================================================================
# Copyright (c) 2022-2023, NVIDIA CORPORATION.
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
rapids_test_record_test_command
-------------------------------

.. versionadded:: v23.04.00

Record the test command that needs to run when executed via ctest after installation

  .. code-block:: cmake

    rapids_test_record_test_command(NAME <name> COMMAND command <args>...)

#]=======================================================================]
function(rapids_test_record_test_command)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.record_test_command")

  set(options)
  set(one_value NAME)
  set(multi_value COMMAND)
  cmake_parse_arguments(_RAPIDS_TEST "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set_property(TEST ${_RAPIDS_TEST_NAME} PROPERTY INSTALL_COMMAND "${_RAPIDS_TEST_COMMAND}")
endfunction()
