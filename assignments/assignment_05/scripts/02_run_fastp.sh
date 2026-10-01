#!/bin/bash
set -ueo pipefail

R1=$1; # allows you to run on any of your samples starting at pos 1 
echo "$R1";
R2="${R1/_R1_/_R2_}";     
echo "$R2";
OUT1="${R1/.subset.fastq/_TRIMMED.fastq}";
echo "$OUT1";
OUT2="${R2/.subset.fastq/_TRIMMED.fastq}";
echo "$OUT2";
PREFIX="${R1%%_R1_*}";
echo "$PREFIX";
SAMPLE="${PREFIX##*_}";
echo "$SAMPLE"

fastp --in1 "$R1" --in2 "$R2" \
      --out1 "../trimmed/$OUT1" --out2 "../trimmed/$OUT2" \
      --trim_front1 8 --trim_front2 8 \
      --trim_tail1 20 --trim_tail2 20 \
      --n_base_limit 0 \
      --length_required 100 \
      --average_qual 20 \
      --json /dev/null \
      --html /dev/null  
