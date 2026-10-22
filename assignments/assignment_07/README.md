# Assignment 07
## 10/18/26
## Isabelle Danforth

# Task 1 -- Set up directory

https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit

```
bora
# set up directory 
cd SUPERCOMPUTING/assignments/assignment_07
mkdir data scripts output slurm_logs
touch assignment_07_pipeline.slurm
touch README.md
cd scripts; touch 00_download_sra.sh 01_download_data.sh 02_clean_reads.sh 03_map_reads.sh
nano 00_download_sra.sh
```

### SCRIPT: **00_download_sra.sh**

Make sure that all scripts can be run from Assignment_07 directory
```
# type the following 
#!/bin/bash
set -euo pipefail
cd ~/programs
wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-alma_linux64.tar.gz
tar -vxzf sratoolkit.tar.gz
rm -r sratoolkit.tar.gz
echo 'export PATH="$HOME/programs/sratoolkit.3.4.1-alma_linux64/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Make the script executable 
```
chmod +x 00_download_sra.sh
```

### Get data from SRA 

- I typed "marine virus" into the search bar. I then filtered for "DNA", "paired", and "Illumina"
- SEARCH DETAILS: (marine[All Fields] AND virus[All Fields]) AND "marine metagenome"[orgn] AND ("biomol dna"[Properties] AND "library layout paired"[Properties] AND "platform illumina"[Properties] AND "filetype fastq"[Properties])
- sent this to run selector 
- then filter based on bytes: 0-5G
- then filter based on library selection: RANDOM
- selected the first 10 that were in the Mb range (initially had Gb sized files, but couldn't download them quickly)
- Then clicked the toggle to read "Selected" and pressed "Metadata" 
- This downloads a CSV file called "SraRunTable.csv", which I renamed to "SraRunTable2.csv"
- Use scp to get SraRunTable2.csv onto HPC folder from local computer


DO THIS FROM YOUR LOCAL COMPUTER
```
exit
scp ~/Downloads/SraRunTable.csv iadanforth@bora.sciclone.wm.edu:~/SUPERCOMPUTING/assignments/assignment_07/data
# you'll be prompted to enter your password 

# go back to bora
bora
cd SUPERCOMPUTING/assignments/assignment_07/data; ll
# yep, CSV file is there (SraRunTable.csv)
```

# Task 2: Download data 

```
cd ../scripts 
nano 01_download_data.sh
```

### SCRIPT: **01_download_data.sh**

Runs from assignment_07 directory
```
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
```

Make script executable 
```
chmod +x 01_download_data.sh
cd ..
```

Run the script (from main directory)
```
bash ./scripts/01_download_data.sh ./data/SraRunTable.csv
```

# Task 3: Clean up reads with fastp 

```
cd scripts 
nano 02_clean_reads.sh
```

### SCRIPT: **02_clean_reads.sh**

NOTE: Requires FASTP program 

```
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
```

```
# make it executable 
chmod +x 02_clean_reads.sh
```

```
# run the script from assignment directory
cd ..
bash ./scripts/02_clean_reads.sh
```

# Task 4 + 5: Map clean reads to dog genome with bbmap and extract with samtools 

For this, you'll want to create a test data set from your trimmed reads and a short 
version of the reference genome. 

Refer to class 10 notes for instructions on bbmap useage

### Make a small test data folder 

```
# STARTING FROM ASSIGNMENT DIRECTORY
mkdir -p ./data/test_data 
for f in ./data/clean/*.fastq; do
    head -n 10000 "$f" > ./data/test_data/$(basename "$f")   # first 10,000 reads
done

# make subset of dog genome 
head -n 10000 ./data/dog_reference/dog_reference_genome.fna > ./data/dog_reference/dog_reference_genome_short.fna
```

Built out the for loop. Once I felt good about it, I added it to a test .sh and ran this 
to see if it would work on my test data 

Run this from assignment directory

```
cd scripts
nano 03_map_reads_test.sh
```

### O3_map_reads_test.sh

```
#!/bin/bash
set -ueo pipefail

# 1. Activate bbmap-env
module load miniforge3 
eval "$(conda shell.bash hook)"
# conda create -y -n bbmpa-env -c bioconda bbmap
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
# conda create -y -n samtools -c conda-forge -c bioconda "samtools>=1.20"
conda activate samtools 
conda env export --no-builds > samtools-env.yml

# 5. Apply samtools
for SAM in ./output/[SE]RR*.sam; do
    SAMPLE=$(basename "$SAM" .sam)
    samtools view -F 4 -q 20 -h "$SAM" > ./output/"${SAMPLE}"_dog_matches.sam
    echo "${SAMPLE}: $(samtools view -c ./output/${SAMPLE}_dog_matches.sam) dog reads"
done
```

```
# make file executable 
chmod +x 03_map_reads_test.sh
```

### Run the test script
```
# go back to main directory and run script to see if it works 
cd ..
bash ./scripts/03_map_reads_test.sh
# it does! 
```

### Now delete everything in ./data/raw ./data/clean, ./output 
```
# now delete everything in ./data/raw ./data/clean, ./output 
cd data
rm -r raw clean test_data dog_reference
cd ..
rm -r output

### Create a test pipeline script 
cd ../scripts
nano test_pipeline.sh
```


### SCRIPT: test_pipeline.sh
```
#!/bin/bash
set -ueo pipefail

# with the first script, remember that you HAVE to give it a table to look for 
bash ./scripts/01_download_data.sh ./data/SraRunTable.csv
# this script runs fine 

bash ./scripts/02_clean_reads.sh
# this scripts runs fine

mkdir -p ./data/test_data 
for f in ./data/clean/*.fastq; do
    head -n 10000 "$f" > ./data/test_data/$(basename "$f")   # first 10,000 reads
done

# make subset of dog genome 
head -n 10000 ./data/dog_reference/dog_reference_genome.fna > ./data/dog_reference/dog_reference_genome_short.fna

bash ./scripts/03_map_reads_test.sh
```

```
# make file executable 
chmod +x test_pipeline.sh
```

```
# run test_pipeline.sh
cd ..
bash ./scripts/test_pipeline.sh
# yayy everything ran fine with the test data

# now delete everything that you just made 
cd data
rm -r clean test_data raw dog_reference 
cd ..
rm -r output 
```


# Task 6 -- Submit job to Slurm

### Create the REAL 03_map_reads.sh (adjust paths to not use test data )
```
cd scripts
nano 03_map_reads.sh

################# ADD THE FOLLOWING TO 03_map_reads.sh ###################
#!/bin/bash
set -ueo pipefail

# 1. Activate bbmap-env
module load miniforge3 
eval "$(conda shell.bash hook)"
# conda create -y -n bbmpa-env -c bioconda bbmap
conda activate bbmpa-env
conda env export --no-builds > bbmap-env.yml

# 2. Apply bbmap
mkdir -p ./output

for FILE in ./data/clean/[SE]RR*.fastq; do
    SAMPLE=$(basename "$FILE" .fastq)    
    echo "Mapping ${SAMPLE}..."

    bbmap.sh -Xmx24g \
        ref=./data/dog_reference/dog_reference_genome.fna \
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
# conda create -y -n samtools -c conda-forge -c bioconda "samtools>=1.20"
conda activate samtools 
conda env export --no-builds > samtools-env.yml

# 5. Apply samtools
for SAM in ./output/[SE]RR*.sam; do
    SAMPLE=$(basename "$SAM" .sam)
    samtools view -F 4 -q 20 -h "$SAM" > ./output/"${SAMPLE}"_dog_matches.sam
    echo "${SAMPLE}: $(samtools view -c ./output/${SAMPLE}_dog_matches.sam) dog reads"
done

```

```
# make file executable (but do not run it, can't do it from login node)
chmod +x 03_map_reads.sh
```

```
cd ..
nano assignment_07_pipeline.slurm

############ ADD THE FOLLOWING TO assignment_07_pipeline.slurm ############### 
#!/bin/bash
#SBATCH --job-name=assignment_07
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=4 
#SBATCH --time=0-04:00:00 
#SBATCH --mem=120G 
#SBATCH --mail-type=FAIL,BEGIN,END 
#SBATCH --mail-user=iadanforth@wm.edu 
#SBATCH -o /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_07/output/assignment_07%j.out 
#SBATCH -e /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_07/output/assignment_07%j.err 

# 1. Download data 
bash ./scripts/01_download_data.sh ./data/SraRunTable.csv

# 2. Clean up data
bash ./scripts/02_clean_reads.sh

# 3. Map reads 
bash ./scripts/03_map_reads.sh
```

```
chmod +x assignment_07_pipeline.sh
sbatch assignment_07_pipeline.sh
```

# Task 7 -- Inspect .err and .out file 
```
cd output; ll
cd ..
```



# Task 8 -- Inspect the files 

### Figure how many samples have dog reads 

```
module load miniforge3 
eval "$(conda shell.bash hook)"
conda activate samtools 

# for one file 
samtools view -c -F 0x904 SRR12345678.sam
# returns 0

samtools flagstat SRR41170409_2_TRIMMED_dog_matches.sam
# also a handy command 

printf "Sample_ID\tTotal_Reads\tDog_Mapped_Reads\n" > ./output/mapped_reads.tsv
# use printf to specify table format

# run from assignment 07 directory
for f in ./output/*_TRIMMED.sam; do
    SAMPLE=$(basename "$f" .sam)
    # use basename to chop off the path and sam extension, leaving just sample ID
    
    TOTAL=$(samtools view -c -F 0x900 "$f")
    
    MAPPED=$(samtools view -c -F 0x904 "$f")

    printf "%s\t%s\t%s\n" "$SAMPLE" "$TOTAL" "$MAPPED" >> ./output/mapped_reads.tsv
    # print f takes SAMPLE, TOTAL, MAPPED (%s) and puts them as tab-separated using the 
   # backslash t 
    
done
```


|       SAMPLE ID       | TOTAL READS | DOG READS |  
| ------------------    | ----------- | --------- |
| ERR3437110_1_TRIMMED	|    320347	  |    0      |
| ERR3437110_2_TRIMMED	|   320347	  |    2      |
| SRR11283661_1_TRIMMED	|    498644	  |    1      |
| SRR11283661_2_TRIMMED	|    498644	  |    1      |
| SRR1425947_1_TRIMMED	|    204023	  |   159     |
| SRR1425947_2_TRIMMED	|    204023	  |   140     |
| SRR1425956_1_TRIMMED	|    232754	  |   108     |
| SRR1425956_2_TRIMMED	|    232754	  |   111     |
| SRR1425970_1_TRIMMED	|    184640	  |    63     |
| SRR1425970_2_TRIMMED	|    184640	  |    67     |
| SRR21418196_1_TRIMMED	|    319130	  |   26372   |
| SRR21418196_2_TRIMMED	|    319130	  |   26456   |
| SRR25009149_1_TRIMMED	|   146418	  |   1666    |
| SRR25009149_2_TRIMMED	|    146418	  |   1707    |
| SRR25009151_1_TRIMMED	|   135103	  |   1776    |
| SRR25009151_2_TRIMMED	|    135103	  |   1763    |
| SRR25009153_1_TRIMMED	|    182287	  |   8214    |
| SRR25009153_2_TRIMMED	|   182287	  |   8140    |
| SRR25009178_1_TRIMMED	|    178784	  |   2659    |
| SRR25009178_2_TRIMMED	|   178784	  |   2660    |
| SRR25009180_1_TRIMMED	|   156424    |   4098    |
| SRR25009180_2_TRIMMED	|   156424	  |   4064    |
| SRR25009185_1_TRIMMED	|    260773	  |   372     |
| SRR25009185_2_TRIMMED	|    260773	  |   389     |
| SRR41170409_1_TRIMMED	|      0	  |    0      |
| SRR41170409_2_TRIMMED |      0      |    0      |




# Task 9 -- Document everything in README
**Reflection:**
This pipeline uses *SRA toolkit* to download files corresponding to marine virus metagenome data from NCBI SRA. 
It then uses *fastp* to filter out low quality reads. The parameters that I used specified that I wanted to remove the first 8
bases and last 20 bases from each of my reads (for and rev). I also specified that if any sequence contained an unknown nucleotide (N),
that read should be discarded. Any reads shorter than 100bp after trimming should also be removed. Lastly, I specified that I 
wanted the mean Phred quality for all retained reads to be greater than 100. Because of these strict parameters, one of my files 
(SRR41170409_1_TRIMMED) contained no reads. 

I found this assignment much harder than previous ones, primarily because I could not run bbmap on the real files. This meant 
that I had to work with a subset of data and I was worried it would not work for the full data. In theory, the actual tasks 
required for this assignment were not difficult, but I found myself making many small mistakes. Not noticing that I had specified 
the file path in 03_map_reads.sh as /output instead of ./output cost me several hours of confusion and frustration. Nonetheless, 
the practice with having to work with test data and then scale it up to the real data was very useful. 


# Task 10 -- Push to GitHub
```
echo "./data/" >> .gitignore
git add .gitignore
git add assignment_07_pipeline.slurm bbmap-env.yml datasets-env.yml output/ README.md samtools-env.yml scripts/
git commit -m "adding assignment_07 content"
git push 
```









