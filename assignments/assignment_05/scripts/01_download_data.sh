#!/bin/bash
set -ueo pipefail
cd data/raw
wget https://gzahn.github.io/data/fastq_examples.tar
tar -tf fastq_examples.tar
# list the files without extracting them
tar -xf fastq_examples.tar -C ~/SUPERCOMPUTING/assignments/assignment_05/data/raw/
# unzip all of the files
gunzip *.fastq.gz
# remove the .tar file
rm fastq_examples.tar
