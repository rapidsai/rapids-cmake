# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

# Read VERSION file (format: YY.MM.PP, e.g., 26.02.00)
file(READ "${CMAKE_CURRENT_LIST_DIR}/../VERSION" _rapids_version)

# Parse VERSION file into components
if(_rapids_version MATCHES [[^([0-9][0-9])\.([0-9][0-9])\.([0-9][0-9])]])
  set(RAPIDS_VERSION_MAJOR "${CMAKE_MATCH_1}")
  set(RAPIDS_VERSION_MINOR "${CMAKE_MATCH_2}")
  set(RAPIDS_VERSION_PATCH "${CMAKE_MATCH_3}")
  set(RAPIDS_VERSION_MAJOR_MINOR "${RAPIDS_VERSION_MAJOR}.${RAPIDS_VERSION_MINOR}")
  set(RAPIDS_VERSION "${RAPIDS_VERSION_MAJOR}.${RAPIDS_VERSION_MINOR}.${RAPIDS_VERSION_PATCH}")
else()
  message(FATAL_ERROR "Failed to parse VERSION file: ${_rapids_version}")
endif()

# Read RAPIDS_BRANCH file
file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/../RAPIDS_BRANCH" _rapids_branch)

# Set rapids-cmake version and branch if not already set Users can override these variables to test
# with different rapids-cmake versions: - rapids-cmake-version: Version number (e.g., 26.02) -
# rapids-cmake-branch: Branch name (e.g., branch-26.02) - rapids-cmake-sha: Specific commit SHA for
# pinned versions - rapids-cmake-tag: Specific tag for releases - rapids-cmake-repo: Alternative
# repository (e.g., user/rapids-cmake)
if(NOT rapids-cmake-version)
  set(rapids-cmake-version "${RAPIDS_VERSION_MAJOR_MINOR}")
endif()

if(NOT rapids-cmake-branch)
  set(rapids-cmake-branch "${_rapids_branch}")
endif()

# Bootstrap rapids-cmake using FetchContent
include("${CMAKE_CURRENT_LIST_DIR}/RAPIDS.cmake")
