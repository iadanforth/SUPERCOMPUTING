# Class 9 - 092926

**LESSON 05**

NOTE: I actually started working through this in the Class8 notes

Summary of tasks learned so far
- HPC use
- navigating 
- running and writing scripts
- moving files to and from HPC
- parameter expansion
- command substitution
- for loops

So now at the point where we can really start doing pretty much anything we want to do

Today, we are going to put together several scripts that each do very specific things that 
we can then string together into a pipeline 

PIPELINE = shell script that calls other shell scripts 
- We will also learn how to include checks in each script 
- We will also learn how to manage environment with things like Conda and Nextflow 
- Some versions of programs will not always be compatible 

```
cd $SHARED_DIR/
cd lesson_05
# remove files from last semester 
ls *interleaved_chop*
# will reveal what matches your pattern
# make sure that these are the right ones 
# OK now remove
rm *interleaved_chop*
# create a class9 folder
cd $HOME/SUPERCOMPUTING/class_notes
mkdir class9_092926
# go back to where the lesson_05 data is kept on the HPC 
cd $SHARED_DIR/lesson_05
# now copy them over to your class9_092426/ 
cp -r * ~/SUPERCOMPUTING/class_notes/class9_092926/
# create a README.md files so that you can push to GitHub
nano README.md
cd DATA
```

## Intro to fastq file
- for bases that look that they have low quality score, you can chop them off 
- software automatically calculates the quality - reported every 4 lines 

```
# look at the first four lines 
head -n 4 S096_S38_L001_R1_sample.fastq 
```

but it's really hard to calculate the number of sequences as we were previously. So 
we are going to use someone else's program to do this. 

we can see that are fastq files are organized as R1 (forward) and R2 (reverse). This is done 
by the sequencer to double check the base calling. If they match, we have good confidence that this 
is correct. 
```
head -1 S090*R1*
head -1 S090*R2*
# SO FIRST LINE OF READ 1 GOES WITH FIRST LINE OF READ 2 
head -2 S090*
# so R1 will read from 5' to 3'
# R2 prints out the reverse complement of R1 (bc it's reading the second strand)
```

I then had Claude make me a python script for generating a table of quality scores. 
I saved this in 'programs' and created a variable in my .bashrc to call it from anywhere 
```
QUAL=$(sed -n '4p' S096_S38_L001_R1_sample.fastq)
python3 "$QUAL_TBL" "$QUAL"
```

# Script for interleaving R1 and R2 files

some people don't like that there are two files. They want the forward read info and then 
interleave them into one file. 

There's also a script that Geoff made in the class8_notes folder called 
'interleave_chop.sh'. This script takes paired fwd and rev fastq files, chops N reads off 
the 3' end, and interleaves the fwd and rev reads into a single output file.

The script takes 4 positional arguments. The forward reads (denoted R1 in the fastq files)
, the paired reverse reads (R2), the name of an output file, and the number of nucleotides to chop off of the 3' end of the reads. It can handle regular or gzipped file formats.

Usage: <R1.fastq[.gz]> <R2.fastq[.gz]> <out.fastq[.gz]> <N_to_chop>
	- very common to chop off last 20 bases because generally low quality
	- 

Example:
./interleave_chop.sh S090_S9_L001_R1_sample.fastq S090_S9_L001_R2_sample.fastq S090_out.fastq 200

### Run interleave.chop
**I created a variable called 'INTERLEAVE_CHOP'. To run the script, do the following**
```
"$INTERLEAVE_CHOP" S090_S9_L001_R1_sample.fastq S090_S9_L001_R2_sample.fastq S090_out.fastq 200
```

**if you don't want to create the 'INTERLEAVE_CHOP' variable, you have to specify paths as follows*

```
# from the class9 folder 
# this works if interleave_chop.sh is present in the class9_092926 folder 
./interleave_chop.sh ./data/S090_S9_L001_R1_sample.fastq ./data/S090_S9_L001_R2_sample.fastq ./data/S090_S9_L001_interleaved_trimmed.fastq 200
cd data/
# can see that the file is now there 
head -8 S090_S9_L001_interleaved_trimmed.fastq 

wc -l S090*
# checks that you now have 80 lines (R1 and R2 files had 40)
```

### Write for loop to apply interleave chop to all of the file 
```
## PARAMETER EXPANSION TO SIMPLIFY THING 
$VAR="myfile_1.txt"
# during expansion, replace 1 with 2
echo ${VAR} ${VAR/1/2} ${VAR/_1.txt/}_output.log
```

RETURNS: myfile_1.txt myfile_2.txt myfile_output.log
# so all you need to know if the name of the forward 
# will then allow you to rename the forward and then name the output log 

```
ls -l *_R1_*
# lists all the forward reads 

for FWD in *_R1_*; do 
$INTERLEAVE_CHOP $FWD; 
done

# or if you don't want to use your saved $INTERLEAVE_CHOP

# check what this looks like before applying your scipt
# from the class9 folder 
for FWD in data/*_R1_*; do 
# echo is nice to keep track
echo ${FWD}; 
REV=${FWD/_R1_/_R2_};
echo ${REV};
OUT=${FWD/_R1_/_interleaved_chopped_};
echo ${OUT};
done

# now apply your script 
for FWD in data/*_R1_*; do 
# echo is nice to keep track
echo ${FWD}; 
REV=${FWD/_R1_/_R2_};
echo ${REV};
OUT=${FWD/_R1_/_interleaved_chopped_};
echo ${OUT};
./interleave_chop.sh ${FWD} ${REV} ${OUT} 200;
done

cd data/
# check that you do in fact have _interleaved_chopped_ files 
ll *chopped*
# prints out everything with a chopped in it
```

# Other variable renaming tricks
#### Some other things that can be done to derive variable names on the fly, beyond just 
find/replace

**Substring removal/trimming**
- ${VAR#pattern}: remove the shortest match of pattern from the front.
- ${VAR##pattern}: remove the longest match from the front.
- ${VAR%pattern}: remove the shortest match from the end.
- ${VAR%%pattern}: remove the longest match from the end.
- Example: VAR="abc.def.txt"; echo ${VAR%.*} → abc.def (strip last extension).

**Substring extraction**
- ${VAR:pos}: get substring starting at pos.
- ${VAR:pos:len}: get len characters starting at pos.
- Example: ${VAR: -3} → last 3 chars.

**Pattern replacement**
- ${VAR/pat/repl}: replace first occurrence.
- ${VAR//pat/repl}: replace all occurrences.
- ${VAR/#pat/repl}: replace only if match at start.
- ${VAR/%pat/repl}: replace only if match at end.

**Case modification (bash ≥ 4)**
- ${VAR^}: capitalize first char.
- ${VAR^^}: uppercase all.
- ${VAR,}: lowercase first char.
- ${VAR,,}: lowercase all.

**String length**
- ${#VAR}: gives length.

**you don't need to memorize them all, just play with them. Claude likes to do 
these all the time. Manipulating strings and making them look nicer for you**

## Practice with parameter expansion and explanations
```
VAR="S090_S9_L001_R1_sample.fastq"

######### SUBSTRING REMOVAL/TRIMMING ############
echo ${VAR%_*}
# strips the shortest possible match of "_*" from the end. 
# finds the LAST underscore in the string 
# and removes from there to the end
# great for just pulling out file names
> S090_S9_L001_R1

echo ${VAR%%_*}
# removes the longest possible match of _* from the end 
# finds the FIRST underscore and removes everything after it
# great for just getting sample number
> S090

echo ${VAR%%_*}_output.log
# as with line 2, starts by finding the FIRST underscore 
# then tacks on _output.log
> S090_output.log

echo ${VAR#_*}
# removes the shortest match to _from the front
# except that VAR doesn't start with a _
# so there is no match, and it returns the same name as VAR
> S090_S9_L001_R1_sample.fastq

echo ${VAR##_*}
# removes the longest match to _ from the front 
# except that VAR doesn't start with a _
# so there is no match, and it returns the same name as VAR 
> S090_S9_L001_R1_sample.fastq

VAR2="_S090_S9_L001_R1_sample.fastq"
echo ${VAR2#_*}
> S090_S9_L001_R1_sample.fastq
echo ${VAR2##_*}
> [EMPTY, NO RESPONSE]

############## SUBSTRING EXTRACTION ##############
echo ${VAR: -5}
# pulls out the last 5 characters in the file 
> fastq

echo ${VAR:4, -3}
>stq

echo ${VAR:10:3}
> 01_
# starting at position 10, take the 3 characters right after that position 
echo ${VAR:5:7}
> S9_L001

############ PATTERN REPLACEMENT ##################
echo ${VAR/_/.}
> S090.S9_L001_R1_sample.fastq
# only replaces the first occurrence of _

echo ${VAR//_/.}
> S090.S9.L001.R1.sample.fastq
# replaces all occurrences of _ 

VAR2="PCR1_sample.fastq"
echo ${VAR2/R1/forward}
> PCforward_sample.fastq  -- WRONG, silently corrupted the sample name
echo ${VAR2/#R1/forward}
> PCR1_sample.fastq       -- unchanged, correctly refuses to match
# so adding the # prevents 'forward' from being added in places where 
# part of the name might match what you're trying to replace 
# similarly, ${VAR/%pat/repl} will replace only if there is a match at the END 

echo ${VAR^}
# capitalizes first character. Since the first character is already capitalized,
# this returns echo ${VAR}

echo ${VAR^^}
S090_S9_L001_R1_SAMPLE.FASTQ
# capitalize everything 

echo ${VAR,}
# lower case first character 
> s090_S9_L001_R1_sample.fastq

echo ${VAR,,}
# lowercase all characters 
> s090_s9_l001_r1_sample.fastq

################ TEST ###############
VAR="S090_S9_L001_R1_sample.fastq"

# why are these all going to give you the same output 
echo ${VAR%%_*}
# this will look for the first _ and then remove everything after it 
> S090

echo ${VAR%_S*}
# this will look for the last _S in the string and remove everything
# the last _S in the string is in _S9_L001.... 
# so everything before it gets removed  
# leaves you with 
> S090

echo ${VAR:0:4}
# this starts at position 0, and takes the first four characters
> S090
```

# SEQTK 

```
cd ~/programs
wget https://github.com/shenwei356/seqkit/releases/download/v2.10.1/seqkit_linux_amd64.tar.gz
tar -xzf seqkit_linux_amd64.tar.gz
cd - 
# "XZF = extract ze file"
# can now delete .gz file 
rm seqkit_linux_amd64.tar.gz

# check that it's in your path
export PATH=$HOME/programs:$PATH
```

### Exploring seqkit 

```
info seqkit
# 'q' to exit
cd ~SUPERCOMPUTING/class_notes/class9_092926/data
seqkit stats *chopped*
# returns this nice table of information 

# we want this on all files not just chooped 
seqkit stats *

# but what if something went wrong?
# you'd want to go back to the for loop and verify that everything is working properly
# this is something that can be automated. 
# Bash isn't good at this, but Python script will easily go through all of the scripts and make sure that they
# are a double of the other two files 
```



### Make more scripts and put together a pipeline

#### intsall_seq_kit.sh

```
#!/bin/bash
set -euo pipefail

cd ~/programs
wget https://github.com/shenwei356/seqkit/releases/download/v2.10.1/seqkit_linux_amd64.tar.gz
tar -xzf seqkit_linux_amd64.tar.gz
cd - 
```
- ran into a small problem with install_seq_kit.sh. I had to make sure it was always being added 
   to my path. So I added this line in the pipeline.sh file
   
   
   
- move interleave_chop.sh to scripts directory. 
- This means that you'll have to update it's relative path in chop_files.sh

#### chop_files.md

```
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
```
		
#### get_stats.sh

```
#!/bin/bash
set -euo pipefail
seqkit stats ./data/*
```

#### pipeline.sh

```
#!/bin/bash
set -euo pipefail
./scripts/install_seq_kit.sh
export PATH=$HOME/programs:$PATH
./scripts/chop_files.sh
./scripts/get_stats.sh
```
	
#### now run the pipeline from the class9 folder
```
./scripts/pipeline.sh ./data/*
```
- Remember that having ./ means "do this from the current directory". So I'm saying to go to 
  the scripts directory where pipeline.sh is stored. Then apply this .sh program to all of
  the files held in the 'data' directory


**make sure to chmod +x all of the scripts to make them executable**




# MISCELLANEOUS OTHER NOTES

*REMEMBER: always include 'set -ueo pipefail' in scripts*


# give bailey read and execute permissions 
```
chmod -R g+rX $HOME/SUPERCOMPUTING/
``` 