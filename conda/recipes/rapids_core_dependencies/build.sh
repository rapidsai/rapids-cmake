# Copyright (c) 2022, NVIDIA CORPORATION.

# Script assumes the script is executed from the root of the repo directory

REPO_DIR=$(cd $(dirname $0); pwd)

SOURCE_DIR=${REPO_DIR}/conda/recipes/rapids_core_dependencies
BUILD_DIR=${BUILD_DIR:=${REPO_DIR}/build}

INSTALL_PREFIX=${INSTALL_PREFIX:=${PREFIX:=${CONDA_PREFIX:=$BUILD_DIR/install}}}
export PARALLEL_LEVEL=${PARALLEL_LEVEL:-4}

for bd in ${BUILD_DIRS}; do
  if [ -d "${bd}" ]; then
      find "${bd}" -mindepth 1 -delete
      rmdir "${bd}" || true
  fi
done

cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_INSTALL_LIBDIR="lib" \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
cmake --build "${BUILD_DIR}" --target install -j${PARALLEL_LEVEL}
