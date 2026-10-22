#!/bin/bash
set -ueo pipefail
mkdir -p ./data/clean
cd ./data/raw
# build out for loop 
# copy from assignment 5 and adjust as needed 
for R1 in *_1.fastq; do
R2="${R1/_1/_2}"
echo "Reading ${R2}";
OUT1="../clean/${R1/.fastq/_TRIMMED.fastq}"
echo "Returning $OUT1";
OUT2="../clean/${R2/.fastq/_TRIMMED.fastq}"
echo "Returning $OUT2";
SAMPLE="${R1%%_1*}"
echo "Sample is named ${SAMPLE}";
fastp --in1 "$R1" --in2 "$R2" \
      --out1 "$OUT1" --out2 "$OUT2" \
      --trim_front1 8 --trim_front2 8 \
      --trim_tail1 20 --trim_tail2 20 \
      --n_base_limit 0 \
      --length_required 100 \
      --average_qual 20 \
      --json /dev/null \
      --html /dev/null 
done
cd ../..
