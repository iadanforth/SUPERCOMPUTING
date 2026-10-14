# Assignment 06 
## 10/12/26
## Isabelle Danforth 

**Topics covered:**

- assembling genomes de novo with Flye 
- Installing programs for genome assembly with three different installation methods
- Utilizing conda

**Assignment summary:**

Here, we developed a pipeline for downloading a file, installing a program (Flye) to assemble 
genomes from that file using (1) local build, (2) modules on HPC, (3) conda environment, and then put 
this together into a script that will run all of these tasks sequentially. In addition, 
a Slurm script was written to carry out the local install of Flye because it was taking too long 
to do on the login node and I was getting kicked out of Bora. 


**Brief comparison of BBMap and Flye**

BBMap
- splice-aware global aligner for DNA or RNA. Can be used with sequences generated via Illumina, Sanger, Ion Torrent
  Pac Bio or Nanopore. 
- **it's purpose is to compare my reads to a refernce genome and figure out where on the genome
  the reads come from**
  	- but this would take forever if it had to go through each nt one at a time
  	- instead, BBMAP builds an index - a lookup table of short subsequences. These are 
      called k-mers and are 13 b long). 
    - so for each read, BBMap breaks it into Kmers and then references them in the table. This 
      gives it a shortlist of candidate locations. Based on this, it then does more extensive alignment of a few spots. 
- "designed for accurate mapping of sequencing reads to referencegenomes"
- will give you read quality, insert-size distributions, genome coverage statistics 
- outputs a .sam file as standard output 
- You build one index per reference, with bbmap.sh ref=genome.fasta. 
  It’s written to a ref/ folder in your current directory.
- Later runs reuse it automatically, so you can just run bbmap.sh in=reads.fq out=mapped.sam 
  from the same directory without ref= again. Run it from elsewhere and you’d point to it with 
  path=/where/the/ref/folder/is.
- If you change the reference, you need to rebuild the index, otherwise BBMap maps against 
  the old one. You can skip writing it to disk with nodisk, e.g. bbmap.sh ref=genome.fasta 
  in=reads.fq out=mapped.sam nodisk. BBMap builds the index in memory for that run only,
  which is handy for small references (bacteria, plasmids, amplicons) where indexing takes seconds anyway.
  
Flye
- de novo genome assembler made for long read sequencing technologies 
- can be used for metagenomic data with metaFlye 
- **takes raw, uncorrected long reads and builds accurate repeat graphs to output 
  polished contigs without needing prior reference genome** 
- While BBMAP gives you a bam/sam file, Flye will give you a .fasta with reconstructed contigs 


**Scripts generated:**
- 01_download_data.sh = download the data and save it in data directory
- 02_flye_2.9.5_conda_install.sh = set up a conda environment for Flye 
- 02_flye_2.9.5_manual_install.sh = install Flye to programs (uses a Slurm script to do this bc wouldn't actually work otherwise)
- 03_run_flye_conda.sh = run Flye using conda environ
- 03_run_flye_local.sh = run Flye using the one in ~/programs 
- 03_run_flye_module.sh = run Flye using the Flye on HPC 
- slurm_flye_local.slurm = install Flye locally by submitting it as a job to HPC 


# Task 1 -- setting up the directory 

Copied the directory structure outline in the assignment. 

```
bora
cd ~SUPERCOMPUTING/assignments
mkdir assignment_06; cd assignment_06
mkdir assemblies data scripts slurm_logs
# added a log directory for the Slurm script that I later had to write 
cd assemblies; mkdir assembly_conda assembly_local assembly_module
cd ..
cd scripts
nano 01_download_data.sh 02_flye_2.9.5_conda_install.sh 02_flye_2.9.5_manual_build.sh 03_run_flye_conda.sh 03_run_flye_local.sh 03_run_flye_module.sh
cd ..
touch flye-env.yml pipeline.sh README.md
```

# Task 2 -- download raw ONT data 

```
cd data
wget -O SRR33939694.fastq.gz 'https://zenodo.org/records/15730819/files/SRR33939694.fastq.gz?download=1'
# this allows you to download the file and name it whatever you want (instead of relying on wget's default method)

# now add the commands above to a script
cd ../scripts
nano 01_download_data.sh

# add the following lines
#!/bin/bash
set -euo pipefail
cd data
wget -O SRR33939694.fastq.gz 'https://zenodo.org/records/15730819/files/SRR33939694.fastq.gz?download=1'

# make script executable 
chmod +x 01_download_data.sh 

# check that it works 
cd ../data 
rm SRR33939694.fastq.gz
cd ..
bash ./scripts/01_download_data.sh 
cd data 
# yup 
```

# Task 3 -- get Fly v2.9.6 LOCAL BUILD 

Kept getting kicked off the supercomputer while trying to get this set up. 
Decided to write a Slurm script and send the job to the supercomputer. 

```
cd ../scripts
nano slurm_flye_local.slurm
```

Slurm script (slurm_flye_local.slurm)
```
#!/bin/bash
#SBATCH --job-name=flye_local_install
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=4 
#SBATCH --time=0-00:30:00 
#SBATCH --mem=120G 
#SBATCH --mail-type=FAIL,BEGIN,END 
#SBATCH --mail-user=iadanforth@wm.edu 
#SBATCH -o /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_06/slurm_logs/flye_manual_install_%j.out 
#SBATCH -e /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_06/slurm_logs/flye_manual_install_%j.err 

cd ~/programs/
git clone https://github.com/fenderglass/Flye
cd Flye
make
echo 'export PATH="$HOME/programs/Flye/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Run slurm script 
```
sbatch slurm_flye_local.slurm
squeue
# check queue 
sacct
# to check progress 
```

# create script to install via local build 
``` 
#!/bin/bash
set -euo pipefail
sbatch ./scripts/slurm_flye_local.slurm
```

make script executable 
```
chmod +x 02_flye_2.9.5_manual_build.sh
```

run script from assignment_06 directory
```
bash ./scripts/02_flye_2.9.5_manual_build.sh
cd ~/programs; ll
# see Flye is there 
# is it in your path?
which flye
# DO NOT TYPE which Flye with a capital F -- keep accidentally doing that 
# yup it's there 
flye --version
```

Task 4 -- get Flye v2.9.6 (conda build)

Steps for conda

1. load module: 'module load miniforge3'
2. evaluate this (pseudo conda init): 'eval "$(conda shell.bash hook)"'
3. create the environment: 'conda create -y -n bbmpa-env -c bioconda bbmap'
4. activate the program: 'conda activate bbmpa-env'
5. conda info --envs
6. get out of conda environ: 'conda deactivate; conda deactivate'

```
# from anywhere, but currently in assignment 06 directory 
module load miniforge3 
echo "$(conda info --base)"
eval "$(conda shell.bash hook)" 
# notice that now there is a (base) in front of username 
mamba create -y -n flye-env -c conda-forge -c bioconda flye
# -y flag automatically says yes to all prompts 
conda activate flye-env
flye --version 
# 2.9.6-b1802
# notice that there is now a (flye-env) in front of username 
# document environment by exporting a yml file of all dependencies and versions 
conda env export --no-builds > flye-env.yml
conda deactivate
conda deactivate 

# Put all of the code above into 02_flye_2.9.5_conda_install.sh
cd scripts 
nano 02_flye_2.9.5_conda_install.sh

# type the following into the .sh file 
#!/bin/bash
set -euo pipefail
module load miniforge3 
echo "$(conda info --base)"
eval "$(conda shell.bash hook)" 
mamba create -y -n flye-env -c conda-forge -c bioconda flye
conda activate flye-env
flye --version 
conda env export --no-builds > flye-env.yml

# make file executable 
chmod +x 02_flye_2.9.5_conda_install.sh

# check that this worked by removing the environment and then 
# reinstalling it with the script 
cd ~ 
conda env list 
conda env remove -n flye-env
# you will get prompted to say Y or N twice 
# go to assignment_06 since this is the project directory and probably where you want 
# to run the script from 
# in which case, the path for flye-env.yml does not need to be changed 
cd SUPERCOMPUTING/assignments/assignment_06
bash ./scripts/02_flye_2.9.5_conda_install.sh
conda env list
# shows the flye-env is there
nano flye-env.yml
# yay, correctly created the environment and stored the .yml file where I wanted it 
```

# Task 5 -- Decipher how to use Flye 

Design a flye command to assemble phage genomes out of this data.

```
conda activate flye-env
flye --help
# since these are high quality reads, I assume we want --nano-hq path
# for number of cpu's to use, bora max is 20. Maybe just request 2? (this is --threads)

# from assignment_06 (project directory)
# make sure to rename the file and specify the path so that it goes to the right place 
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_conda/flye_phage_assembly --threads 2
# but then we need the log file and .fasta to go to the 'assembly_conda' environment
cd assemblies/assembly_conda/flye_phage_assembly
mv assembly.fasta ../conda_assembly.fasta 
mv flye.log ../conda_flye.log
# then remove the 'flye_phage_assembly' directory
cd ..
rm -r flye_phage_assembly
ll
# looks good 
```


# Task 6a -- Write a script to run Flye using Conda

```
# now turn the code above into the script -- "03_run_flye_conda.sh"
# again - you're running this from assignment_06 directory
cd ../../scripts
nano 03_run_flye_conda.sh

# put the following lines into this script 
#!/bin/bash
set -euo pipefail
module load miniforge3 
echo "$(conda info --base)"
conda activate flye-env
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_conda/flye_phage_assembly --threads 2
cd assemblies/assembly_conda/flye_phage_assembly
mv assembly.fasta ../conda_assembly.fasta 
mv flye.log ../conda_flye.log
rm -r flye_phage_assembly

#
make it executable
chmod +x 03_run_flye_conda.sh

# now delete your previous assemblies and run the script to see if it works 
cd ../assemblies/assembly_conda
rm conda_assembly.fasta conda_flye.log
cd ../..
bash ./scripts/03_run_flye_conda.sh
cd assemblies/assembly_conda; ll
# confirm that only the two files that you want are there 
# iterate through this process until it's correct 
# mostly just kept forgetting to give the right path

# get out of conda environ and miniforge 
conda deactivate
conda deactivate
```

# Task 6b -- Write a script to run Flye using local build  

```
# from assignment_06 directory 
cd scripts; nano 03_run_flye_local.sh
```

Type the following into 03_run_flye_local.sh
```
set -euo pipefail
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_local/flye_phage_assembly --threads 2
cd assemblies/assembly_local/flye_phage_assembly
mv assembly.fasta ../local_assembly.fasta 
mv flye.log ../local_flye.log
# then remove the 'flye_phage_assembly' directory
cd ..
```

Make it executable
```
chmod +x 03_run_flye_local.sh
```

Make sure that this now works 
```
cd ..
bash ./scripts/03_run_flye_local.sh

cd assemblies/assembly_manual; ll 
# can see that only the log file and the .fasta file are there - perfect
```


# Task 6c -- Write a script to run Flye using module environ

```
cd ~
module avail
# can see the Flye is there (Flye/gcc-11.4.1/2.9.6 )
# ok now go to assignment_06 directory 
cd SUPERCOMPUTING/assignments/assignment_06 
module load Flye
flye --version 
# 2.9.6-b1802
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_module/flye_phage_assembly --threads 2
# now need to move some files around and delete as you did with the conda build 
cd assemblies/assembly_module/flye_phage_assembly
mv assembly.fasta ../module_assembly.fasta 
mv flye.log ../module_flye.log
# then remove the 'flye_phage_assembly' directory
cd ..
rm -r flye_phage_assembly
ll
# looks good 
# delete the files 
rm -r module_flye.log module_assembly.fasta 

# turn it into a script 
cd ../../scripts; nano 03_run_flye_module.sh

# type following into '03_run_flye_module.sh'
#!/bin/bash
set -euo pipefail
module load Flye
flye --nano-hq ./data/SRR33939694.fastq.gz --out-dir ./assemblies/assembly_module/flye_phage_assembly --threads 2
cd assemblies/assembly_module/flye_phage_assembly
mv assembly.fasta ../module_assembly.fasta 
mv flye.log ../module_flye.log
cd ..
rm -r flye_phage_assembly

# make it executable 
chmod +x 03_run_flye_module.sh

# delete previous files and run script to make sure that it works 
cd..
cd assemblies/assembly_module
rm module_assembly.fasta module_flye.log 
cd ../..
# run from assignment_06 directory 
bash ./scripts/03_run_flye_module.sh 

# verify that files are in the right place 
cd assemblies/assembly_module; ll 
# yup, they're there! 

```

# Task 7 -- compare the results in the log files 

what kind of info is in the last 10 lines?
```
tail -10 module_flye.log 
# essentially summary statistics

# to get all three assembly files at once, use a wildcard for both the 
# assembly folder and the _flye.log file within each of them
cd ../..
tail -n 10 assemblies/assembly_*/*_flye.log
```

- interestingly, the path for the files is actually wrong because I manually moved them after the program ran.
- is there a way to tell Flye to send one of the output files somewhere else? 

# Task 8 -- build a 'pipeline.sh' script 

Type the following into the 'pipeline.sh' script
```
nano pipeline.sh

# type the following 
#!/bin/bash
set -euo pipefail

# Download file 
bash ./scripts/01_download_data.sh

# Install Flye (local build)
bash ./scripts/02_flye_2.9.5_manual_build.sh

# Install Flye (conda)
bash ./scripts/02_flye_2.9.5_conda_install.sh

# Run Flye in Conda environment
bash ./scripts/03_run_flye_conda.sh

# Run Flye using local build
bash ./scripts/03_run_flye_local.sh

# Run Flye using module 
bash ./scripts/03_run_flye_module.sh

tail -n 10 assemblies/assembly_*/*_flye.log
```

# Task 9 -- Check that pipeline.sh is working 

Now delete the data file, the Flye programs (in ~/programs), the conda environment and all of the assemblies
Run the pipeline script to make sure that you get the right output 

```
cd ../assemblies/assembly_conda; rm -r conda_*
cd ../assembly_local; rm -r local_*
cd ../assembly_module; rm -r module_*
cd../data; rm -r SRR* 
cd../slurm_logs
rm -rf flye_env_local_*
# delete the error and output files from the flye local install 
cd ~/programs; ll
rm -rf Flye
```

Return to assignment 06 directory and run the full pipeline script 
```
cd ../SUPERCOMPTING/assignments/assignment_06
bash pipeline.sh
# let it do it's thing
```
Once the script finishes running, you should get the summary statistics printed out to the screen one 
after the other. 

From these, you can see that there are no differences in total genome length, number of fragments, 
or their mean coverage across the Flye runs using different install techniques. This is what 
I would expect as long as the program versions were identical (which they were - all 2.9.6). 

Verify that everything is where it should be 
```
ll
cd slurm_logs; ll
# see error and output files from Slurm 
cd ../data; ll
# see data file is there 
cd ../assemblies/assembly_conda; ll
# see that files are there 
cd ../assembly_local; ll
# see that files are there 
cd ../assembly_module; ll
```

After confirming that this is all correct, push these files all to Git Hub - **EXCEPT FOR 
THE FASTQ FILE**
```
# add a README file to the /data directory so that it pops up on Github 
cd ../../data
nano README2.md
cd ~/SUPERCOMPUTING/assignments 

git add assignment_06/assemblies assignment_06/scripts assignment_06/slurm_logs assignment_06/flye-env.yml assignment_06/pipeline.sh assignment_06/data/README2.md
git commit -m "add all assignment 06 content except for README file"
git push
# verify that this worked on Git Hub
# exit bora and download everything onto local machine
```

# Task 10 -- Document in README.md 

**Reflection:** 

I really enjoyed this assignment as it finally felt like I was going through a process 
that was directly relevant to my research. Previous assignments were undoubtedly useful, but 
this was the first one where I felt genuinely comfortable with and confident about what I 
was doing. 

I encountered two primary challenges. First, I struggled to manually install Flye on the log
in node. The commands were working as they should be and I could see Flye appear in ~/programs. 
Running "which flye" returned the right path and "flye --version" returned the correct version, so all 
seemed to be going normally. However, I did notice that I kept getting kicked off of bora after 
trying to install Flye. Although I was not concerned about this at first, I eventually realized that 
the 'make' command had not correctly run because bora was timing me out. Because of this, I received an 
error message when trying to actually run the program, prompting me to verify that 'make' correctly ran. 
To resolve this, I created a Slurm script to send the job to a bora node, which properly installed Flye in just a 
minute. This was useful as I got to practice writing a Slurm script and integrating it into another script 
that would install Flye. I envision this being particularly useful when I eventually try to 
install complex programs that cannot be installed from a login node. 

Beyond this initial challenge with installing Flye, my main errors were related to setting 
the correct path. Fortunately, these errors were more related to mistakes and not a misunderstanding 
about defining the right path. For instance, I would forget that the script was running from the assignment 06 
directory, and would try to 'cd' into a folder that actually existed in a subdirectory. 

I prefer the conda environment method. Using modules available on the HPC is by far the 
most straightforward approach, but I think that this would limit by ability to test out 
newly published programs for viral genomic work and ultimately slow my research down. Installing 
manually offers the greatest versatility and might be useful if there is a specific version that I want,
but it seems cumbersome and time consuming. In contrast, setting up conda environments is quick, clean,
and will minimize conflicts between different programs. I have experienced the pain of 
writing code for a particular version of an R package (ggsurv), only for another package (ggplot2)
to update and ruin the perfect code that I had written for ggsurv. In the next assignment,
I will probably use a conda environment, though I can see how manual installation or modules 
may have their advantages in some cases. 

