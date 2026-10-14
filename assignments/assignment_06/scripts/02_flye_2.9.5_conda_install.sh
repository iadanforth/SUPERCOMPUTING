#!/bin/bash
set -euo pipefail
module load miniforge3 
echo "$(conda info --base)"
eval "$(conda shell.bash hook)" 
mamba create -y -n flye-env -c conda-forge -c bioconda flye
conda activate flye-env
flye --version 
conda env export --no-builds > flye-env.yml

