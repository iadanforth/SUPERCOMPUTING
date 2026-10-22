#!bin/bash
set -ueo pipefail

bash ./scripts/01_download_data.sh ./data/SraRunTable.csv

bash ./scripts/02_clean_reads.sh

mkdir -p ./data/test_data 
for f in ./data/clean/*.fastq; do
    head -n 10000 "$f" > ./data/test_data/$(basename "$f")   # first 10,000 reads
done

# make subset of dog genome 
head -n 10000 ./data/dog_reference/dog_reference_genome.fna > ./data/dog_reference/dog_reference_genome_short.fna

bash ./scripts/03_map_reads_test.sh
