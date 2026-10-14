set -euo pipefail
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_local/flye_phage_assembly --threads 2
cd assemblies/assembly_local/flye_phage_assembly
mv assembly.fasta ../local_assembly.fasta 
mv flye.log ../local_flye.log
# then remove the 'flye_phage_assembly' directory
cd ..
rm -r flye_phage_assembly

