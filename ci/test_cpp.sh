#!/bin/bash

#!/bin/bash

set -euo pipefail

rapids-logger "Create test conda environment"
. /opt/conda/etc/profile.d/conda.sh

rapids-dependency-file-generator \
  --generate conda \
  --file_key test \
  --matrix "cuda=${RAPIDS_CUDA_VERSION%.*};arch=$(arch);py=${RAPIDS_PY_VERSION}" > env.yaml

rapids-mamba-retry env create --force -f env.yaml -n test
set +eu
conda activate test
set -u


rapids-logger "Check GPU usage"
nvidia-smi

rapids-logger "Begin cpp tests"
cmake -S testing -B build

cd build
ctest --output-on-failure
exitcode=$?

exit ${SUITEERROR}
