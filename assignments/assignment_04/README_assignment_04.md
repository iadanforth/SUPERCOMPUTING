# Assignment 04 
## Isabelle Danforth
## 092326

First create directory for assignment 4 and create a README file on your local machine 
Then, push to git hub
```
cd SUPERCOMPUTING/assignments/assignment_04
touch README_assignment_04.md 
cd ..
git add assignment_04
git commit -m "add assignment 04 read me (empty)"
git push
# check that this worked by going to GitHub repository
```

Then, go to bora (must be connected to WM VPN)
```
bora 
# enter credentials
cd SUPERCOMPUTING/
git pull
# make sure your directories look the same on the supercomputer as they do on git hub
```

# Task 1: creating a special directory in $HOME called "programs"
```
# what is your home?
echo $HOME
# now see if there is a programs directory here
cd ~ 
ls
# see that there is a directory called programs 
```

# Task 2: download and unpack the gh "tarball"

- in assignment 01, we downloaded an used a program called *gh* to handle github credentials 
- this is what allows you to push and pull from the command line 
- here, we want to write a script that automates the installation of gh, following the 
  same process used to install it manually 
- go here: https://github.com/cli/cli
- look for the file 'gh_2.74.2_linux_amd64.tar.gz' 
- https://github.com/cli/cli/releases/download/v2.74.2/gh_2.74.2_linux_amd64.tar.gz

Download this file from the command line and unpack into programs

```
cd programs/
wget https://github.com/cli/cli/releases/download/v2.74.2/gh_2.74.2_linux_amd64.tar.gz
ls 
tar -xzvf gh_2.74.2_linux_amd64.tar.gz
# x — extract files from the archive
# z — decompress using gzip (for .tar.gz / .tgz files)
# v — verbose, print each file name as it's extracted
# f — read from the file named next on the command line
rm -r gh_2.74.2_linux_amd64.tar.gz
ll
```

# Task 3: build a bash script from task 2 
- Call the script 'install_gh.sh' and store it in programs/. 
- the script should include the process used in task 2 
```
nano install_gh.sh
# copy paste lines 47-56 from this file 
# remember to add "#!/bin/bash" at the top
```


# Task 4: add the location of the gh binary to your $PATH
```
# open up your .bashrc file
nano /sciclone/home/iadanforth/.bashrc
# under the 'SET SHARED DIRECTORY VARIABLE' section
# add the new path to the gh binary (call it GH_BINARY)
# /sciclone/home/iadanforth/programs/gh_2.74.2_linux_amd64/bin/gh
# ctrl X to get out of nano
# verify that this worked 
source ~/.bashrc
echo $GH_BINARY 
```

# Task 5: Run gh auth login to setup your username and password

From home 
```
cd ~
# run the program as follows 
bash /sciclone/home/iadanforth/programs/install_gh.sh
cd programs
ls
# should now see the file 'gh_2.74.2linux_amd64' in the programs directory
cd ..
SUPERCOMPUTING/gh_2.74.2_linux_amd64/bin/gh auth login

```
- hit 'enter' to select 'GitHub.com'
- hit 'enter' to select 'HTTPS'
- hit 'enter' or type 'Y' to say "yes"
- hit 'enter' to select 'Login with authentication token'
- copy the authentication token

# Task 6: Create another installation script (for seqtk)
```
cd programs/
touch install_seqtk.sh
# open up install_seqtk.sh
nano install_seqtk.sh
# add the following lines
# cd programs/
# git clone https://github.com/lh3/seqtk.git;
# cd seqtk; make
# echo "export SEQTK_BIN=$PATH:/sciclone/home/iadanforth/programs/seqtk/seqtk" >> ~/.bashrc
```

run the install_seqtk.sh script
```
cd ~ 
bash /sciclone/home/iadanforth/programs/install_seqtk.sh
# verify that it is in your bash.rc
source ~/.bashrc
# ask for the lines where the new variable assignment is in the .bashrc
grep -n SEQTK_BIN ~/.bashrc
# line 165
# open .bashrc
nano /sciclone/home/iadanforth/.bashrc
# yep, it is there
# now test
echo $SEQTK_BIN
```

# Task 7: figure out seqtk

get the .fna file and add it to assignment 04 (I deleted it from the assigment 03 folder)
```
cd SUPERCOMPUTING/assignments/assignment_04
mkdir data
cd data
wget https://gzahn.github.io/data/GCF_000001735.4_TAIR10.1_genomic.fna.gz
gunzip GCF_000001735.4_TAIR10.1_genomic.fna.gz
ls
# file is now in data directory within assignment_04
```

see what seqtk does
```
$SEQTK
# returns the possible  commands
# maybe try size?
# from assignment_04/data, run 
$SEQTK_BIN size GCF_000001735.4_TAIR10.1_genomic.fna
# so there are 7 sequences, and 119668634 bases
$SEQTK_BIN telo GCF_000001735.4_TAIR10.1_genomic.fna
# ok, no telomeres 
$SEQTK_BIN comp GCF_000001735.4_TAIR10.1_genomic.fna > seq_comp.csv
# very cool 
$SEQTK_BIN seq GCF_000001735.4_TAIR10.1_genomic.fna > seq_full.txt
```

# Task 8: Write a 'summarize_fast.sh' script

The goal is now to write a script that will:
1. Take the name of a fasta file as a position argument ($1)
2. Store the filename as a variable
3. Calculate and store as variables (or tmp files)
	- total number of sequences
	- total number of nucleotides
	- table of sequence names and lengths for all seqs 
4. report information as the stdout with explanatios

```
cd ..
mkdir script
cd script
# create a directory to store the script file(s)
touch summarize_fasta.sh
``` 

draft out what should be in the nano
- definitely want to start with "!bash..."
- task 1 and 2 are just 
```
FASTA_FILE=$1
```
then try figuring out the rest by breaking it into pieces
```
FILE1="/sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_04/data/GCF_000001735.4_TAIR10.1_genomic.fna"

$SEQTK_BIN size "$FILE1"|cut -f1
# so this isolates out the number of sequences 

$SEQTK_BIN size "$FILE1"|cut -f2
# and this isolates out number of nucleotides
# so if I want these saved as outputs, just need to name them something 
# but remember that you don't want the echo program to just spit back useless information

NUM_SEQ=$("$SEQTK_BIN" size "$FILE1" | cut -f1)
echo "$NUM_SEQ"
# gives you the number 7

NUM_BP="$SEQTK_BIN size "$FILE1"|cut -f2"
# if you run this, saying echo "NUM_BP" gives you the path for each variable and then the cut -f2 stuff, 
# not actual numbers of bp. Need to modify as follows:
# make the variable the actual output of your commands
NUM_BP=$("$SEQTK_BIN" size "$FILE1" | cut -f2) 

# next, we know that 'comp' creates the table of all the sequences with the name length and numbers for 
# each nt type and a bunch of other information
# we just want a table of sequence names and lengths, so just the first two pieces of info
$SEQTK_BIN comp "$FILE1" | cut -f1,2
# running this line accomplishes this
# so as before, name this something and save it as a tab delimited file 
TABLE=$("$SEQTK_BIN" comp "$FILE1" | cut -f1,2)

# ok now need a way to send to stout
# you can just use echo in the actual .sh file 
```

Go into the file and add your script 
```
nano summarize_fasta.sh
```

**SCRIPT**
```
#!/bin/bash
FASTA_FILE=$1

NUM_SEQ=$("$SEQTK_BIN" size "$FASTA_FILE" | cut -f1)

NUM_BP=$("$SEQTK_BIN" size "$FASTA_FILE" | cut -f2)

TABLE=$("$SEQTK_BIN" comp "$FASTA_FILE" | cut -f1,2)

# OUTPUT
echo "here are the number of sequences contained within the file $FASTA_FILE"
echo "$NUM_SEQ"

echo "here are the number of base pairs across all sequences in the file $FASTA_FILE"
echo "$NUM_BP"

echo "lastly, here are the names for all sequences in as well as the number of nucleotides in each sequence for the file $FASTA_FILE"
echo "$TABLE"
```

run it
```
chmod +x summarize_fasta.sh 
./summarize_fasta.sh /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_04/data/GCF_000001735.4_TAIR10.1_genomic.fna
```

# Task 9: Run the script on several files
The sequences that I downloaded from GenBank all correspond to Chlorovirus genomes, 
one from each major groups. 

I did this by searching "Chlorovirus" in the NCBI search bar, clicking on the Assembly that I wanted 
going to the FTP, and getting the path information for the .fna.gz file
```
# go back to the data directory in assignment_04
cd ..
cd data
# acquire some sequences from GenBank
 wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/873/685/GCF_000873685.1_ViralProj20989/GCF_000873685.1_ViralProj20989_genomic.fna.gz
 wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/847/045/GCF_000847045.1_ViralProj14564/GCF_000847045.1_ViralProj14564_genomic.fna.gz
 wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/887/825/GCF_001887825.1_ViralProj355304/GCF_001887825.1_ViralProj355304_genomic.fna.gz
 wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/869/685/GCF_000869685.1_ViralProj18527/GCF_000869685.1_ViralProj18527_cds_from_genomic.fna.gz
 gunzip GCF_000873685.1_ViralProj20989_genomic.fna.gz GCF_001887825.1_ViralProj355304_genomic.fna.gz GCF_000847045.1_ViralProj14564_genomic.fna.gz GCF_000869685.1_ViralProj18527_cds_from_genomic.fna.gz 
# now have 5 FASTA files
```

```
# make a new directory for output
cd ..
mkdir summary_output
cd summary_output
# run the following in that directory
for FILE in /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_04/data/*.fna; do
    FILENAME=$(basename "$FILE" .fna)
    /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_04/script/summarize_fasta.sh "$FILE" > "${FILENAME}_summary.tab"
done
ls
# can now see that there a files with the summary output of the fasta files
# open one to check that it looks good 
nano GCF_000847045.1_ViralProj14564_genomic_summary.tab
```

# Task 10: Verify your README file and reflection
I initially misunderstood the assignment and set the variable $GH_BINARY as the full path 
to the script 'install_gh.sh'. When I began writing the script for installing seqkt, I realized
that this made no sense since it wouldn't call the actual program. I then went back and fixed 
the file path to direct to the actual 'gh' program. I also ran into trouble when I tried to push my
entire 'assignment_04' directory to GitHub because I had large .fna files left in the 'data' directory.
To resolve this, I decided to delete the entire repository from the SUPERCOMPUTER, clone it 
again, and then add all files except for the data directory within 'assignment_04'. This assignment
also helped me to become much more conceptually comfortable with naming variables, calling them,
and identifying places where this would be particularly useful. I think that some of the discussion
in class was too abstract for me to really understand what the practical purpose of this is, but it 
is very clear now. I also appreciated learning how to write and run a script. In a previous molecular
evolution workshop that I attended, they repeatedly discussed how we could write scripts to automate
analyses. I understood what that meant but not how I would actually do this in practice. My understanding of $PATH is that it simplifies the process of writing out where
an item is stored. If I need to run the program 'gh', I don't want to repeatedly copy paste the entire path. 
Also, the path for my computer will be different from the path for another computer. Having stored variable resolves this 
challenge.



# Task 11: Push to GitHub
**I did not add the 'data' directory because it contains large files. Therefore, there 
there is no data directory on GitHub**

```
cd ~
cd SUPERCOMPUTING/assignments/assignment_04
git status
# we don't want to push the .fna files to git hub
# did not git add the entire data directory
git add script/ summary_output/
git commit -m "add assignment_04, not the data"
```

