#!/bin/bash
set -euo pipefail

# Download file 
bash ./scripts/01_download_data.sh

# Install Flye (local build)
bash ./scripts/02_flye_2.9.5_manual_build.sh

# Install Flye (conda)
bash ./scripts/02_flye_2.9.5_conda_install.sh

# Run Flye in Conda environment
bash ./scripts/03_run_flye_conda.sh

# Run Flye using local build
bash ./scripts/03_run_flye_local.sh

# Run Flye using module 
bash ./scripts/03_run_flye_module.sh

tail -n 10 ./assemblies/assembly_*/*_flye.log
