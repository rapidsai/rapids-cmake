# Copyright (c) 2022, NVIDIA CORPORATION.

# Script assumes the script is executed from the root of the repo directory

REPO_DIR=$(cd $(dirname $0); pwd)

SOURCE_DIR=${REPO_DIR}/conda/recipes/rapids_core_dependencies
BUILD_DIR=${BUILD_DIR:=${REPO_DIR}/build}

INSTALL_PREFIX=${INSTALL_PREFIX:=${PREFIX:=${CONDA_PREFIX:=$BUILD_DIR/install}}}
export PARALLEL_LEVEL=${PARALLEL_LEVEL:-4}

# If the dir to clean is a mounted dir in a container, the
# contents should be removed but the mounted dirs will remain.
# The find removes all contents but leaves the dirs, the rmdir
# attempts to remove the dirs but can fail safely.
if [ -d "${BUILD_DIR}" ]; then
  find "${BUILD_DIR}" -mindepth 1 -delete
  rmdir "${BUILD_DIR}" || true
fi

cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_INSTALL_LIBDIR="lib" \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
cmake --build "${BUILD_DIR}" --target install -j${PARALLEL_LEVEL}
