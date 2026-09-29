#!/bin/bash
set -euo pipefail

for FWD in data/*_R1_*; do 
# echo is nice to keep track
echo ${FWD}; 
REV=${FWD/_R1_/_R2_};
echo ${REV};
OUT=${FWD/_R1_/_interleaved_chopped_};
echo ${OUT};
./scripts/interleave_chop.sh ${FWD} ${REV} ${OUT} 200;
done
