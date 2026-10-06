# Class 10 Notes 
## Lesson 06: Reproducible Environments 

## QUIZ5: Build a pipeline
   - here, we created a script that would run three scripts together as a pipeline 
   - I'd like to follow up to understand how to determine where you are when you run the script 

## Creating more reproducible environments 

- **self-contained workspace** = defines which programs, libraries, and setting are available
  for a job or workflow 
   - this helps avoid conflicts between tools (like two programs needing two versions of the 
      the same library)
   - **SOFTWARE TOOLS TO MANAGE OTHER SOFTWARE TOOLS** --> many options for this (primarily Pixie or Conda)
   
- for instance, lets say that your new version of R doesn't work with code written in old R version. 
  You could re-install the old version, but that's a pain because now you have two versions 
  
- Docker essentially packages the whole computer 

- Conda takes all of the software libraries together (this is what we call a **conda environment**)

```
module avail
module load seqkit/
# installs seqkit 


# many subcommands 
# module avail = what modules are available
# module = total software environemnts that do not need to be installed 
# if you want a module added you can ask the HPC group to add it 

# we can see many options
# if you're using neural networks, you might be using cuda/12.3 
# but if you need version 12.4, you need to get a new version 

# now we don't have to add seqkit or moose to your path if you change the version
# so now in your script, you can just run 'module load seqkit' 
```

Avoiding conflicts between tools can be done in several ways 
1. Modules on the HPC
2. Conda environ
3. Manual local installs (what we've been doing thus far)

## Environment management tools 
### Modules 
- admin builds tools for you in a sleek, easy and **less reproducible** way 

### Conda
- thug -- takes over you entire account -- rewrites .bashrc script 

### DIY
- requires you to document everything in scripts. Sometimes called "local build"

### Docker
- if you want to collaborate with people, you need people to know how Docket works 
- like a shipping container for software 
- huge data requirements, can be a pain on HPC systems 

**ADD PHOTO OF TABLE**


# Add CONDA to your Supercomputer account 
```
module load miniforge3 
which conda # shows that yes, you have conda 
conda --version # tells you what version of conda you're running
# when we install conda on our local computer, we will have to install manually and put it in 
# our path 

# ABSOLUTELY DO NOT RUN 'conda init'
# you do this once and conda will take over .bashrc so that it runs itself 
# this can be fixed by deleting all of the conda stuff from your .bashrc 
# saying conda init will result in your heading being changed to (base)...

# INSTEAD OF RUNNING conda init - run this 
# add this too all scripts running conda
eval "$(conda shell.bash hook)"     


conda create -y -n bbmpa-env -c bioconda bbmap
# what is this doing 
# we will probably use mamba instead of conda 
conda activate bbmap-env 
```

- a lot of Geoffs pipelines have these lines 
```
module load miniforge3 
eval "$(conda shell.bash hook)" 
``` 

# installing conda and activating a software on the HPC 
```
# 1. load module
module load miniforge3 
which conda
# 2. evaluate this (pseudo conda init)
eval "$(conda shell.bash hook)"
# 3. create the environment  
conda create -y -n bbmpa-env -c bioconda bbmap
# activate the program
conda activate bbmpa-env
conda info --envs
#to get out, you need to click conda deactivate twice 
conda deactivate
conda deactivate

#you know that you're in the enviro if it reads (bbmpa-env)
```

ok, so we're now in bbmap environment

```
bbmap.sh
#shows all of the stuff thats possible 
bbmap.sh -v
#lists version of the program
``` 

so in this case we have multiple conda environments, each for a specific program. The reason why we do this 
is so that two programs that require two different version of python (for instance) are not conflicting.

ideally, you want all programs working in same conda environment. But this might not always be possible. Conda will tell you if that is 
going to happen 

to create a conda enviro with multiple programs 
```
conda create -y -n NEW-env bbmap iqtree [insert whatever additional programs you want] -c bioconda    
```  

# RUNNING BBMAP
```
~/SUPERCOMPUTING/class_notes/class10_100126
mkdir script 
nano 01_download.sh
```

### script for '01_download.sh'
```
#!/bin/bash
set -ueo pipefail
wget https://zenodo.org/records/15733378/files/ecoli_and_lambda.tar
tar -xf ecoli_and_lambda.tar
rm ecoli_and_lambda.tar
```

### now use bbmap 

```
conda activate bbmpa-env
conda info --envs
bbmap.sh
# great so we're in our bbmap conda environment (bbmap-env)

# run bbmapstats.sh
bbstats.sh lambda_reads.fastq 
bbstats ecoli_bl21de3.fasta 

# now, lets look for phage genome inside of 
bbmap.sh ref=ecoli_bl21de3.fasta in=lambda_reads.fastq out=mapping.sam nodisk=t ambiguous=best minid=0.9 threads=2
# this gives you the 'mapping.sam' environment
# but in order to actually search for lambda genomes, you're going to have to actually download SAM tools 
# YOU CAN PROBABLY HAVE THESE IN THE SAME ENVIRONMENT 
```


### making this reproducible

  - this code can be run from anywhere (doesn't need to be outside of the conda environment )

```
conda env export -n bbmpa-env --from-history > bbmpa-env.yaml
#but prefix lists my path which isn't going to be the one for others 
conda env export -n bbmpa-env --from-history | grep -v "^prefix:" > bbmpa-env.yaml
```


# QUESTIONS 
- still confused about the idea of putting things in your $PATH. Why did I have to type that export 
  command at one point. How do I know if something is in my $PATH. Does it have to be in my .bashrc?
- what is the bioconda channel
   - online repositories for installing different softwares
   - bioconda is good for bioinformatics stuff 
   - conda-forge is where bbmap lies, which is why your channel reads conda-forge 
