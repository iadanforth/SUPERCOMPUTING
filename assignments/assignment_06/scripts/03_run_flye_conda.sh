#!/bin/bash
set -euo pipefail
module load miniforge3 
echo "$(conda info --base)"
conda activate flye-env
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_conda/flye_phage_assembly --threads 2
cd assemblies/assembly_conda/flye_phage_assembly
mv assembly.fasta ../conda_assembly.fasta 
mv flye.log ../conda_flye.log
cd ..
rm -r flye_phage_assembly
