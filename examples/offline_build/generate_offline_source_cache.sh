#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0

# This script configures and builds the project with a CPM_SOURCE_CACHE pointing
# to a directory of your choice. CPM will download all dependencies into that
# cache during the build. Once complete, the cache directory can be transferred
# to an airgapped or offline system and used with use_offline_source_cache.sh.
#
# Usage:
#   ./generate_offline_source_cache.sh <cache-dir>
#
# Arguments:
#   cache-dir   Absolute path to the directory where CPM will store downloaded sources.
#               The directory will be created if it does not exist.
#
# Example:
#   ./generate_offline_source_cache.sh /tmp/my_cpm_cache

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <cache-dir>"
  exit 1
fi

CACHE_DIR="$1"

echo "Populating CPM source cache at: ${CACHE_DIR}"

BUILD_DIR="$(mktemp -d)"

cmake -S "${SCRIPT_DIR}/src" \
      -B "${BUILD_DIR}" \
      -DCPM_SOURCE_CACHE="${CACHE_DIR}"

cp -r "${BUILD_DIR}/_deps/rapids-cmake-src" "${CACHE_DIR}/rapids-cmake"

rm -rf "${BUILD_DIR}"

echo ""
echo "Cache populated successfully at: ${CACHE_DIR}"
echo ""
echo "To build offline using this cache, run:"
echo "  ./use_offline_source_cache.sh ${CACHE_DIR} <offline-build-dir>"
