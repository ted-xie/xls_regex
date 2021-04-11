#!/bin/bash

export gitroot=$(git rev-parse --show-toplevel)
cd $gitroot
# Clone XLS
(
  set -euo pipefail
  [[ ! -d xls ]] && git clone https://github.com/google/xls
  cd xls
  git checkout 14d5f6e7ba1fd553cdfc9a0d5cb772c1c3ea75cf
)
[[ $? -gt 0 ]] && echo "ERROR: XLS checkout failed!" && exit 1

# Build XLS and XLScc
(
  set -euo pipefail
  cd $gitroot/xls
  bazel build //xls/dslx:interpreter_main //xls/dslx:ir_converter_main \
    //xls/tools:opt_main //xls/tools:codegen_main //xls/contrib/xlscc:xlscc
)
[[ $? -gt 0 ]] && echo "ERROR: XLS build failed!" && exit 1

# Build donut c++ model
(
  set -euo pipefail
  cd $gitroot/src_cc
  make run
)
[[ $? -gt 0 ]] && echo "ERROR: Donut C-model check failed!" && exit 1

# Build donut XLS IR
(
  set -euo pipefail
  cd $gitroot/src_cc
  XLS_HOME=$gitroot/xls make donut.ir
)
[[ $? -gt 0 ]] && echo "ERROR: Donut XLScc IR generation failed!"

echo "SUCCESS!"
