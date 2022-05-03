#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/cython/init.cmake)

rapids_cython_init()
if(NOT DEFINED RAPIDS_CYTHON_INITIALIZED)
  message(FATAL_ERROR "rapids_cython_init didn't correctly set RAPIDS_CYTHON_INITIALIZED")
endif()

STRING(REGEX MATCHALL "*--directives*" matches "${CYTHON_FLAGS}")
LIST(LENGTH matches num_directives)

if(NOT DEFINED CYTHON_FLAGS OR num_directives NOT EQUAL 1)
  message(FATAL_ERROR "rapids_cython_init didn't correctly set CYTHON_FLAGS")
endif()

rapids_cython_init()
if(num_directives NOT EQUAL 1)
  message(FATAL_ERROR "rapids_cython_init is not idempotent")
endif()
