# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/find.cmake)
include(${rapids-cmake-dir}/cpm/package_override.cmake)

rapids_cpm_init()

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/override.json
     [=[
{
  "packages": {
    "dlpack": {
      "version": "1.3",
      "git_url": "https://github.com/dmlc/dlpack.git",
      "git_tag": "v${version}",
      "source_subdir": ".rapids-cmake-download-only/dlpack"
    }
  }
}
  ]=])
rapids_cpm_package_override(${CMAKE_CURRENT_BINARY_DIR}/override.json)

# `DOWNLOAD_ONLY` requests a different, un-overridden version. If the override isn't respected this
# fetches v0.8 instead of the override's v1.3 (see
# https://github.com/rapidsai/rapids-cmake/issues/1088)
rapids_cpm_find(dlpack 0.8
                CPM_ARGS
                GIT_REPOSITORY https://github.com/dmlc/dlpack.git
                GIT_TAG v0.8
                GIT_SHALLOW TRUE
                DOWNLOAD_ONLY ON
                EXCLUDE_FROM_ALL ON)

if(TARGET dlpack)
  message(FATAL_ERROR "DOWNLOAD_ONLY should not add dlpack as a build target")
endif()

find_package(Git REQUIRED)
execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags WORKING_DIRECTORY "${dlpack_SOURCE_DIR}"
                OUTPUT_VARIABLE fetched_tag OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT fetched_tag STREQUAL "v1.3")
  message(FATAL_ERROR "DOWNLOAD_ONLY ignored the package override, fetched '${fetched_tag}' instead of the override's 'v1.3'"
  )
endif()
