#!/bin/bash

set -ueo pipefail
./scripts/01_download_data.sh
cd data/raw

for R1 in *_R1_001.subset.fastq; do
	echo "Trimming ${R1}"
	bash ../../scripts/02_run_fastp.sh "$R1"
done  
