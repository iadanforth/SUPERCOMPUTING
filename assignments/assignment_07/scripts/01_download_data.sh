#!/bin/bash
set -euo pipefail

# 1. Get datasets program 
module load miniforge3 
echo "$(conda info --base)"
eval "$(conda shell.bash hook)" 
#conda create -y -n datasets-env -c conda-forge ncbi-datasets-cli
conda activate datasets-env
conda env export --no-builds > datasets-env.yml

RUN_TABLE="${1:-./data/SraRunTable.csv}"   
# this allows you to run the script by providing it with the .csv file that you want
RAW_DIR="./data/raw"
# set a directory for where your raw data will go
REF_DIR="./data/reference"
# set a directory for where the dog genome will go
 
mkdir -p "$RAW_DIR" "$REF_DIR"
# make those two directories appear 
 
# 2. Download raw reads with fasterq-dump 
# tail -n +2  : skip the header line
# cut -d',' -f1 : take the first column ("Run")
# tr -d '"\r' : strip any quotes or Windows line endings

for ACC in $(tail -n +2 "$RUN_TABLE" | cut -d',' -f1 | tr -d '"\r'); do
    echo "Downloading ${ACC}..."
    fasterq-dump "$ACC" --split-files --outdir "$RAW_DIR" --progress
done


# 3. Download the Canis familiaris reference genome only 
# --reference restricts the download to the RefSeq reference genome
# --include genome returns just the genomic FASTA
datasets download genome taxon "Canis familiaris" \
    --reference \
    --include genome \
    --filename "${REF_DIR}/canis_familiaris_ref.zip"
 
unzip -o "${REF_DIR}/canis_familiaris_ref.zip" -d "$REF_DIR"

#4. Lots of clutter in the dog_reference folder -- clean it up 
mkdir ./data/dog_reference
mv ./data/reference/ncbi_dataset/data/GCF_011100685.1/GCF_011100685.1_UU_Cfam_GSD_1.0_genomic.fna ./data/dog_reference/dog_reference_genome.fna
rm -r ./data/reference
