#!/bin/bash

set -euo pipefail

cd data/raw
wget https://gzahn.github.io/data/fastq_examples.tar
tar -tf fastq_examples.tar
# list the files without extracting them
tar -xf fastq_examples.tar -C ~/SUPERCOMPUTING/assignments/assignment_05/data/raw/
# unzip all of the files
gunzip *.fastq.gz
# remove the .tar file
rm fastq_examples.tar

cd ~/SUPERCOMPUTING/assignments/assignment_05

# now we want to clean up the files
# we want to run this for loop from the 'assignments_05' folder 
# and then we want the trimmed files to be saved the to ./data/trimmed folder
for FWD in ./data/raw/*_R1_*; do 
echo "${FWD}"; 
REV="${FWD/_R1_/_R2_}";
echo "${REV}";
NAME=$(basename "${FWD}");
OUT="./data/trimmed/${NAME/_R1_/_interleaved_chopped_}";
echo "${OUT};"
./scripts/interleave_chop.sh "${FWD}" "${REV}" "${OUT}" 200;
done
