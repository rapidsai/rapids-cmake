#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0

# This script configures and builds the project entirely offline by pointing
# CPM at a pre-populated source cache. No network access is required as long as
# the cache directory contains all required dependencies.
#
# The following CPM variables are set to enforce offline operation:
#
#   CPM_SOURCE_CACHE        - Directs CPM to use the provided cache directory
#                             for all dependency sources instead of downloading.
#   CPM_USE_LOCAL_PACKAGES  - Instructs CPM to attempt find_package() first
#                             before falling back to the source cache, picking up
#                             any system-installed packages automatically.
#
# Usage:
#   ./use_offline_source_cache.sh <cache-dir> <build-dir>
#
# Arguments:
#   cache-dir   Path (absolute or relative) to the CPM source cache populated by
#               generate_offline_source_cache.sh.
#   build-dir   Path (absolute or relative) to the directory where the offline build will
#               be configured and compiled.
#
# Example:
#   ./use_offline_source_cache.sh /tmp/my_cpm_cache /tmp/offline-build

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <cache-dir> <build-dir>"
  exit 1
fi

CACHE_DIR="$(cd "$1" && pwd)"
BUILD_DIR="$(mkdir -p "$2" && cd "$2" && pwd)"

if [ ! -d "${CACHE_DIR}" ]; then
  echo "Error: cache directory does not exist: ${CACHE_DIR}"
  echo "Run generate_offline_source_cache.sh first to populate the cache."
  exit 1
fi

echo "Configuring offline build using CPM source cache at: ${CACHE_DIR}"

cmake -S "${SCRIPT_DIR}/src" \
      -B "${BUILD_DIR}" \
      -DRAPIDS_LOGGER_HIDE_ALL_SPDLOG_SYMBOLS=OFF \
      -DCPM_SOURCE_CACHE="${CACHE_DIR}" \
      -DCPM_USE_LOCAL_PACKAGES=ON \
      -Drapids-cmake-dir="${CACHE_DIR}/rapids-cmake/rapids-cmake/" \
      -DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE="${CACHE_DIR}/rapids-cmake/rapids-cmake/"

echo "Building..."
cmake --build "${BUILD_DIR}"

echo ""
echo "Offline build completed successfully."
echo "Executable: ${BUILD_DIR}/offline_build_example"
