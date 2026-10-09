# Project: Exploring Booker et al. 2026 data on K. brevis associated viruses
# Kbrevis virome 

```
module load miniforge3 
eval "$(conda shell.bash hook)" 

# create a conda environment to house this program "sra-tools"
# and install the "sra-tools" program
conda create -n sra -c conda-forge -c bioconda sra-tools

# this print out your environments
# can now see one called sra 
conda info --envs

# verify that it worked 
conda activate sra
prefetch --version
# once you hit activate sra, you;ll see a little parentheses appear by your name, indicating
that you are in the sra enviro 

cd SUPERCOMPUTING/cd projects
mkdir data; cd data
mkdir raw clean; cd raw 
```

# Acquire the data 

```
# start small - just one file
prefetch SRR28004141
fasterq-dump SRR28004141 --split-files
gzip SRR28004141_*.fastq

###########################
### could also use curl ### 
curl -O "https://ftp.sra.ebi.ac.uk/vol1/fastq/SRR280/041/SRR28004141/SRR28004141_[1-2].fastq.gz"

# or if you want all of the files in the experiment 
# can also be modifed to get every sequence in the project itself 
curl "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=SRX23656680&result=read_run&fields=run_accession,fastq_ftp"
#############################


############################
## inspecting .sra files ### 
############################

````
fastq-dump -X 5 -Z --split-files SRR28004141.sra
vdb-dump --info SRR28004141.sra
vdb-validate SRR28004141.sra 

````
# faster way is to just download all files in the program
cd /sciclone/scr10/iadanforth
# install in scr10 because huge files

curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA1077797&result=read_run&fields=run_accession,sample_alias,fastq_bytes,fastq_ftp" > runs.tsv
cat runs.tsv

grep -o 'ftp\.sra\.ebi\.ac\.uk[^;[:space:]]*' runs.tsv | while read url; do
  curl -O -C - "https://$url"
done

# sra toolkit alternative
tail -n +2 runs.tsv | cut -f1 > run_ids.txt
prefetch --option-file run_ids.txt
for r in $(cat run_ids.txt); do fasterq-dump $r --split-files && gzip ${r}_*.fastq; done
```


