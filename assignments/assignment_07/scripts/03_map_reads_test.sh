#!/bin/bash
set -ueo pipefail

# 1. Activate bbmap-env
module load miniforge3 
eval "$(conda shell.bash hook)"
# the line below can be removed if environment already exists 
#conda create -y -n bbmpa-env -c bioconda bbmap
conda activate bbmpa-env
conda env export --no-builds > bbmap-env.yml

# 2. Apply bbmap
mkdir -p ./output

for FILE in ./data/test_data/[SE]RR*.fastq; do
    SAMPLE=$(basename "$FILE" .fastq)    
    echo "Mapping ${SAMPLE}..."

    bbmap.sh -Xmx24g \
        ref=./data/dog_reference/dog_reference_genome_short.fna \
        in="$FILE" \
        out=./output/"${SAMPLE}".sam \
        nodisk=t ambiguous=best minid=0.9 threads=2
done

# 3. Get out of bbmap 
conda deactivate
conda deactivate 

# 4. Activate samtools-env
module load miniforge3 
eval "$(conda shell.bash hook)"
#conda create -n samtools -c conda-forge -c bioconda "samtools>=1.20"
conda env export --no-builds > samtools-env.yml
conda activate samtools 

# 5. Apply samtools
for SAM in ./output/[SE]RR*.sam; do
    SAMPLE=$(basename "$SAM" .sam)
    samtools view -F 4 -q 20 -h "$SAM" > ./output/"${SAMPLE}"_dog_matches.sam
    echo "${SAMPLE}: $(samtools view -c ./output/${SAMPLE}_dog_matches.sam) dog reads"
done
