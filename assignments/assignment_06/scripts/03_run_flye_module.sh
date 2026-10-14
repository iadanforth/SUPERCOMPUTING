#!/bin/bash
set -euo pipefail
module load Flye
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_module/flye_phage_assembly --threads 2
cd assemblies/assembly_module/flye_phage_assembly
mv assembly.fasta ../module_assembly.fasta 
mv flye.log ../module_flye.log
cd ..
rm -r flye_phage_assembly
