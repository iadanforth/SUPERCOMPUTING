# Assignment 05 
## Isabelle Danforth
## 09/29/26 


# Task 1: Setup assignment_05 directory
```
cd ~/SUPERCOMPUTING/assignments
mkdir assignment_05
cd assignment_05
nano README_assignment_05.md 
mkdir data log scripts
cd data
mkdir raw trimmed
cd ../scripts
nano 01_download_data.sh
nano 02_run_fastp.sh
cd ..
nano pipeline.sh
```

# Task 2: Script to download and prepare fastq data 
- Download the files found here: https://gzahn.github.io/data/fastq_examples.tar
- write a script that accomplishes the following
	(1) downloads the data file 
	(2) extracts the contents 
	(3) puts all fastq files into ./data/raw/
	(4) cleans up the 'fastq_examples.tar' file
	
- name this script './scripts/01_download_data.sh'

```
cd scripts
nano 01_download_data.sh
```

### 01_download_data.sh script

```
#!/bin/bash
set -ueo pipefail
cd data/raw
wget https://gzahn.github.io/data/fastq_examples.tar
tar -tf fastq_examples.tar
# list the files without extracting them
tar -xf fastq_examples.tar -C ~/SUPERCOMPUTING/assignments/assignment_05/data/raw/
# unzip all of the files
gunzip *.fastq.gz
# remove the .tar file
rm fastq_examples.tar
# ctrl x
```

### Run the 01_download_data.sh script from assignment_05
```
# make the file executable
chmod +x 01_download_data.sh

cd ~/SUPERCOMPUTING/assignments/assignment_05
./scripts/01_download_data.sh
cd data/raw
ll
# see all of the files are there 
# some of the numbers towards the end of the file don't match up... weird 
```

# Task 3: Install and explore the fastp tool 

```
cd ~/programs
wget http://opengene.org/fastp/fastp
chmod a+x ./fastp
ll 
# verify that fastp is there 
# ok now that we know that this process works, just copy that over the the nano file
nano install_fastp.sh
```

### 'install_fastp.sh' script
```
#!/bin/bash

set -euo pipefail

cd ~/programs
wget http://opengene.org/fastp/fastp

# to download a specific version
# mv fastp.1.3.3 fastp
wget http://opengene.org/fastp/fastp
chmod a+x ./fastp
echo 'export FASTP_BIN=/sciclone/home/iadanforth/programs/fastp' >> ~/.bashrc
```

```
rm fastp
# remove fastp so that you can run the script and make sure that it's working
```

```
# run the script from ~/programs

./install_fastp.sh 
ll
# can see that fastp is back in the directory
# now check that the path correctly copied into .bashrc
# first ask bash to find the line where the FASTP_BIN is
grep -n FASTP_BIN ~/.bashrc
# it's line 169
nano /sciclone/home/iadanforth/.bashrc
# ok so I can see that the path is there...
# ADD THIS TO THE .bashrc
export PATH="$HOME/programs:$PATH" 
source ~/.bashrc
echo $FASTP_BIN
# returns the full path - looks correct 
```


### Using fastp 

DESCRIPTION OF COMMANDS BELOW
- the -i is the input file for read 1 
- the -I is the input file for read 2 
- the -o is the OUTPUT file for read 1 
- the -O is the output file for read 2 
- Using these arguments (1) removes adapter sequences, (2) removes low quality reads,
  (3) removes reads with too many unknown bases, (4) removes short reads, (5) keeps pairs
   together
- the summary output that prints to your screen will tell you what exactly happened between
  the input and output files (e.g. how many reads were considered low quality)

```
# check out what fastp does to make sure that it's working 
fastp -h
# returns all of the possible commands
cd ~/SUPERCOMPUTING/assignments/assignment_05/data/raw 
head -10 *_196_*

# run the python script that you wrote to get quality tables
QUAL=$(sed -n '4p' 6083_196_S200_R2_001.subset.fastq)
python3 "$QUAL_TBL" "$QUAL"
# just skimming through this one sample, it looks like all of the positions have good support 
# highest p error is 0.06, which I think is ok 
# so probably don't need to trim anything 

# lets start by exploring fastp functionality with a smaller subset of the reads contained in
# assignment_05/data/raw 
mkdir fastp_test
cp *_18* ./fastp_test
cd fastp_test
# copy over a few files into the folder
# run some fastp commands

fastp -i 6083_180_S180_R1_001.subset.fastq -I 6083_180_S180_R2_001.subset.fastq \
	  -o 6083_180_S180_R1_001_OUTPUT.fastq -O 6083_180_S180_R2_001_OUTPUT.fastq \
	  -h report_S180.html -j report_S180.json
	  
# now a for loop that does the same process as above but for all of my test files
for R1 in *_R1_001.subset.fastq; do
  R2="${R1/_R1_/_R2_}"                          # 6083_180_S180_R2_001.subset.fastq
  OUT1="${R1/.subset.fastq/_OUTPUT.fastq}"      # 6083_180_S180_R1_001_OUTPUT.fastq
  OUT2="${R2/.subset.fastq/_OUTPUT.fastq}"      # 6083_180_S180_R2_001_OUTPUT.fastq
  PREFIX="${R1%%_R1_*}"                         # 6083_180_S180
  SAMPLE="${PREFIX##*_}"                        # S180

  echo "Processing ${SAMPLE}"
  fastp -i "$R1" -I "$R2" -o "$OUT1" -O "$OUT2" \
        -h "report_${SAMPLE}.html" -j "report_${SAMPLE}.json"
done
```

Fastp can do a lot of other things 
  - You can specify your adapter sequence to remove those specifically (--adapter_sequence)
  - You can cut out poly A tails if its RNA (--trim_oply_x)
  - You can specify that you're working with an interleaved file (--interleaved_in)
  - The main purpose of fastp is for preprocessing raw sequencing reads so that they are 
    good for analysis. Typically step one after you get fastq FILES. Overwrite the files you made
    with the commands on line 168 will this:

### Explore other possibilities in fastp
```
for R1 in *_R1_001.subset.fastq; do
  R2="${R1/_R1_/_R2_}"                          # 6083_180_S180_R2_001.subset.fastq
  OUT1="${R1/.subset.fastq/_OUTPUT.fastq}"      # 6083_180_S180_R1_001_OUTPUT.fastq
  OUT2="${R2/.subset.fastq/_OUTPUT.fastq}"      # 6083_180_S180_R2_001_OUTPUT.fastq
  PREFIX="${R1%%_R1_*}"                         # 6083_180_S180
  SAMPLE="${PREFIX##*_}"                        # S180

  echo "Processing ${SAMPLE}"
  fastp -i "$R1" -I "$R2" -o "$OUT1" -O "$OUT2" -n 2 -l 50 -y -Y 30 -h "report_${SAMPLE}.html" -j "report_${SAMPLE}.json"
  done
   
   
  # -n 2 = maximum number of N bases allowed is now 2 (the default is 5)
  # -l 50 = the minimum length of a read after trimming is now 50 (default is 15)
  # -y = low complexity filter (usually off)
  # -Y = says that the threshold of low complexity is low. So the 30 means that at least 30% of bases have to be different from the one next to them

```

# Task 4: Script to run fastp

We now want to write a shell script that takes a single name (FORWARD READ (R1)), gets R2 
  from it (REVERSE) and the forward/reverse output file names and any log file names
   - actually, this is basically what you did above 
   - program accepts a minimum of four file names (the two input files - R1 and R2, and the two 
      output files)
   - make sure that the script works on one file, and then put it in the './pipeline.sh' script 
      in a for loop that will take all of the samples one by one 
   - parameters are specified in the assignment 

**QUESTION: why is it better to have the for loop include the script instead of writing the script as 
a for loop (which is what I did below)?**

```
cd ..
# start by running on one sample
R1=6083_180_S180_R1_001.subset.fastq
echo "$R1"
R2="${R1/_R1_/_R2_}"       
echo "$R2"
OUT1="${R1/.subset.fastq/_TRIMMED.fastq}"
echo "$OUT1"
OUT2="${R2/.subset.fastq/_TRIMMED.fastq}"
echo "$OUT2"
PREFIX="${R1%%_R1_*}"
echo "$PREFIX"
SAMPLE="${PREFIX##*_}"
echo "$SAMPLE"
# ok so all the command substitutions look like they are working properly


# now update the fastp commands that you used previously to have the right fastp parameters 
# is the /dev/null where we just send the json into a black hole?
fastp --in1 "$R1" --in2 "$R2" \
      --out1 "../trimmed/$OUT1" --out2 "../trimmed/$OUT2" \
      --trim_front1 8 --trim_front2 8 \
      --trim_tail1 20 --trim_tail2 20 \
      --n_base_limit 0 \
      --length_required 100 \
      --average_qual 20 \
      --json /dev/null \
      --html /dev/null 
# run to see if it works -- it does!
# verify that output files went to trimmed 
cd ../trimmed
ll
# yup
```

### Don't run this - this is how you could do it as a for loop 
```
# now put it together in a for loop
cd ~/SUPERCOMPUTING/assignments/assignment_05/data/raw

# lastly, add in the for loop
# make sure that output files get sent to data/trimmed 
# run from the /data/raw directory 
for R1 in *_R1_001.subset.fastq; do
  R2="${R1/_R1_/_R2_}";                         # for $R1, where there is _R1_ replace with _R2_ (= 6083_001_S1_R2_001.subset.fastq)
  echo "Reading ${R2}";
  OUT1="../trimmed/${R1/.subset.fastq/_TRIMMED.fastq}";    # for $R1, where there is .subset.fastq, replace with _TRIMMED.fastq (= 6083_001_S1_R1_001_TRIMMED.fastq)
  echo "Returning $OUT1";
  OUT2="../trimmed/${R2/.subset.fastq/_TRIMMED.fastq}";    # for $R2, where there is .subset.fastq, replace with _TRIMMED.fastq (= 6083_001_S1_R1_001_TRIMMED.fastq)
  echo "Returning $OUT2";
  PREFIX="${R1%%_R1_*}";                        # for $R1, find the first "_R1_" and chop off everything after that (including _R1_) for all files (= 6083_001_S1)
  # note that you do not need a PREFIX for R2 because R1 and R2 share the same prefix 
  echo "Prefix is for ${PREFIX}";
  SAMPLE="${PREFIX##*_}";                       # for $PREFIX, find the longest match to _ from the front and return everything after it (= S1)
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
```


### Add commands above into 02_run_fastp.sh script

```
cd ~/SUPERCOMPUTING/assignments/assignment_05/scripts
nano 02_run_fastp.sh
```

Add the following to 02_run_fastp.sh
  - make sure to include a line in the OUT1 and OUT2 section that send the output to data/trimmed 

```
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
```

### Make '02_run_fastp.sh' excutable 

```
chmod +x 02_run_fastp.sh 

# save it to bash rc for easy calling
nano /sciclone/home/iadanforth/.bashrc
source ~/.bashrc
echo $RUN_FASTP
# great, it's there 

# now go to /assignment_05/data/raw
cd ~/SUPERCOMPUTING/assignments/assignment_05/data/raw
# run the script to make sure that it works as it did when you were running it outside of script

$RUN_FASTP 6083_196_S200_R1_001.subset.fastq
# great! 

# now delete all of the files in trimmed 
cd ../trimmed
rm *


```

# Task 5: 'pipeline.sh' script

This script combines the first script (01_download_data.sh) to download the tarball and all of
the fastq files it contains. These are then stored in ~/SUPERCOMPUTING/assignments/assignment_05/data/raw
These files are then fed into a for loop. The for loop iterates through all files containing 
"_R1_001.subset.fastq" and runs the second script on these files. The second script then
applies the commands specified using fastp (e.g. removing first 8 bases from the forward read or 
the last 20 bases from forward)

```
cd ../..
nano pipeline.sh
```

### 'pipeline.sh' script 
   - Run this file from the assignment_05 directory

```
#!/bin/bash

set -ueo pipefail

./scripts/01_download_data.sh

# should be in data/raw

for R1 in *_R1_001.subset.fastq; do
	echo "Trimming ${R1}"
	bash ../../scripts/02_run_fastp.sh "$R1"
	# provide relative path from data/raw to get into scripts directory and access .sh
	# the .sh should already direct output files to trimmed directory
done 

```

### Now run 'pipeline.sh' from 'assignment_05' folder 
```
# first, delete raw and trimmed directories
cd data
rm -r raw trimmed 
mkdir raw trimmed 

# now run script from assignment 05 
cd ..
bash pipeline.sh

# check that it worked 
cd data/raw 
ll
cd ../trimmed
ll
# looks good!
```

# Task 7: Document everything in README.md

REFLECTION:
The primary challenges that I encountered were related to typing the syntax correctly. 
Conceptually, I understand the task at hand and how to practically achieve it. But I become
overwhelmed by wondering where I should but the semicolon, or where there should be a space 
here or not. I think that this is something that comes with practice as I felt the same 
way when learning R. 

I enjoyed going through the process of actually using a program on a set of files. I 
routinely read papers listing out the programs they used to accomplish various steps of their 
pipeline, and it is exciting to finally do it myself (albeit at a much smaller scale). 
None of the material in this assignment felt exceptionally new as we had gone through a similar
process in class. I did appreciate learning about the functionality of fastp and what it should
be used for. Working with these scripts also forced me to become more comfortable with relative 
paths and generally being aware of where I was in my path and where the script was being directed. 

The principle reason for splitting the two tasks into two scripts is that each script 
has a specific niche. The 01_download_data.sh script is adept at acquiring and unpacking 
a set of fastq files. The 02_run_fastp.sh script is build to iterate through all of these 
files and trim them based on specifications set by the user. It also returns useful information
such as the number of reads before and after trimming. To accomplish complicated tasks, these scripts 
are then piped together so that they can each carry out the task that they are specialized for. This is 
advantageous because it can speed up the processing of many files and allows you to more easily break apart
which part of the pipeline is failing if an issue arises. This also makes it easier to use one pipeline 
for many different files or projects. However, increasing the number of scripts
also increases the opportunities for small errors that can propagate. 

# Task 8: Push to GitHub

**do not git add the tarball or any fastq files**

add all of these files to git ignore 









``
