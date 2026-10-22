#!/bin/bash
#SBATCH --job-name=assignment_07
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=4 
#SBATCH --time=0-04:00:00 
#SBATCH --mem=120G 
#SBATCH --mail-type=FAIL,BEGIN,END 
#SBATCH --mail-user=iadanforth@wm.edu 
#SBATCH -o /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_07/output/assignment_07_%j.out 
#SBATCH -e /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_07/output/assignment_07__%j.err 

# 1. Download data 
bash ./scripts/01_download_data.sh ./data/SraRunTable.csv 

# 2. Clean up data
bash ./scripts/02_clean_reads.sh

# 3. Map reads 
bash ./scripts/03_map_reads.sh
