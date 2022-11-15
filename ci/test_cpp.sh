#!/bin/bash

set -euo pipefail

rapids-logger "Create test conda environment"
. /opt/conda/etc/profile.d/conda.sh

rapids-dependency-file-generator \
  --output conda \
  --file_key test \
  --matrix "cuda=${RAPIDS_CUDA_VERSION%.*}" | tee env.yaml

rapids-mamba-retry env create --force -f env.yaml -n test
set +eu
conda activate test
set -u

# Disable `sccache` S3 backend since compile times are negligible
unset SCCACHE_BUCKET

rapids-print-env

rapids-logger "Check GPU usage"
nvidia-smi

rapids-logger "Begin cpp tests"
cmake -S testing -B build

cd build
ctest --schedule-random --output-on-failure
exitcode=$?

exit ${exitcode}
