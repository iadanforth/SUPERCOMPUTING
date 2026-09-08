# Assignment 02 
### 090826
### Isabelle Danforth

* Pre-assignment: connected to W&M VPN with 'gp.wm.edu'


 
## Task 1: Set up your semester workspace on the HPC
**ON HPC**
- Go into the supercomputer with the 'bora' alias (= ssh iadanforth@bora.sciclone.wm.edu)
- enter into your assignment_02 folder and create a new directory called "data"

```
bora
ls 
cd SUPERCOMPUTING/
cd assignments/
ls
cd assignment_02
ls
mkdir data 
ls
```

## Task 2: Download files from NCBI via command-line FTP
**ON LOCAL MACHINE**
- Go back to local machine 
- Use ftp command to connect to the NCBI FTP server 
- I did not know what the ftp command was, so I ran to view information on the command. 
- And 'q' to exit.

```
exit
pwd
man ftp
q
```

Enter the 'data' directory in your 'assignment_02' folder. 
```
cd SUPERCOMPUTING/
tree
cd assignments/assignment_02/data
```
Now run the following to establish ftp access with this database in NCBI
```
ftp ftp.ncbi.nlm.nih.gov
```
I got an error message saying that the 'ftp' command was not found
I ran the following to install ftp-style command
```
brew install inetutils
```

this worked and I then re-ran
```
ftp ftp.ncbi.nlm.nih.gov
```
then typed in 'anonymous' as my name and 'iadanforth@vims.edu' when prompted for password
```
ls
cd genomes
cd all/GCF
cd 000/005/845
cd GCF_000005845.2_ASM584v2
binary
get GCF_000005845.2_ASM584v2_genomic.fna.gz
get GCF_000005845.2_ASM584v2_genomic.gff.gz
```

## Task 3: File transfer and permissions

**ON LOCAL MACHINE**
- Get out of the FTP system by typing 'bye'
```
bye
pwd
```
check that you now have the two files that you wanted 
```
ls
```
- yay, they are there 
- now open FileZilla and follow prompts in assignment
- upload the two files to REMOTE computer
- You can do this by going to where the files are stored on your local computer (left side of the 
FileZilla screen), clicking them both and dragging them to where you want them to appear 
on the REMOTE computer (inside of the 'data' folder nested within 'assignment_02)

### Check the permissions of the files 
**ON HPC***
- from local computer, type:
```
bora
cd SUPERCOMPUTING/assignments/assignment_02
ls
cd data
ls
```

yes, the two files appear there!
now check their permissions

*note: ll is an alias for ls -alh that we set up in class*
```
ll
```
you'll see that the permissions are listed 
-rw-------.
this translates to "regular file (-), read and write access to the OWNER, and no access to anyone in the group or anyone outside of the group"
so you need to make this file accessible to everyone 
```
chmod a+r GCF_000005845.2_ASM584v2_genomic.fna.gz
chmod a+r GCF_000005845.2_ASM584v2_genomic.gff.gz
```
now check that it worked 
it did! I think? Permissions now read "-rw-r--r--."

## Task 4: Verify file integrity with md5sum
**ON LOCAL MACHINE***
- exit out of the remote computer and check where you are on the local computer
```
exit
pwd
```
- run the md5sum command on the two files that you downloaded 
- first, check out what md5sum is (can also consult notes in Lesson_02)
- Essentially, this command generates a fingerprint for the file
- Used to confirm that your FTP download and FileZilla upload did not corrupt the data 

```
man md5sum
q
md5sum GCF_000005845.2_ASM584v2_genomic.fna.gz
md5sum GCF_000005845.2_ASM584v2_genomic.gff.gz
```

- OUTPUT 1: c13d459b5caa702ff7e1f26fe44b8ad7  GCF_000005845.2_ASM584v2_genomic.fna.gz
- OUTPUT 2: 0f52ffc94af5ddf544ff89cc6f546b0c  GCF_000005845.2_ASM584v2_genomic.gff.gz

**ON HPC**
now go to bora and run the same md5sum commands there. Copy and past the outputs
```
bora
cd SUPERCOMPUTING/assignments/assignment_02/data
md5sum GCF_000005845.2_ASM584v2_genomic.fna.gz
md5sum GCF_000005845.2_ASM584v2_genomic.gff.gz
```

- OUTPUT 1: c13d459b5caa702ff7e1f26fe44b8ad7  GCF_000005845.2_ASM584v2_genomic.fna.gz
- OUTPUT 2: 0f52ffc94af5ddf544ff89cc6f546b0c  GCF_000005845.2_ASM584v2_genomic.gff.gz


Amazing, the output run from local machine and from HPC match.

## Task 5: Create useful Bash aliases
**ON LOCAL MACHINE**
Ok now access your .bashrc file 
Go to home directory

```
exit
cd ~ 
ll
nano .bash_profile
```
Update your aliases following instructions on assignment 
Copy and pasting the exact code from the assignment initially caused an error. 
After some googling and AI'ing, I found out that this is because 
Mac's ls command doesn't support the "--group-directories-first" flag. 
My solution to this was to install GNU coreutile with Homebrew

```
brew install coreutils
nano .bash_profile
source ~/.bash_profile
```

Now they work! 
Here's what they mean:

alias u='cd ..;clear;pwd;gls -alFh --group-directories-first'
 - this says "go back one directory level, clear the terminal screen, print the current directory and list everything in that directory. 
 - The -a flag says that I want hidden files shown, in long format (-l) with the type of file shown by symbols (-F) and to only show file sizes human readable (-h). 
 - The --group-directories first call is saying to list the directories first in the list.

alias d='cd -;clear;pwd;gls -alFh --group-directories-first'
 - this is similar to u command, except that the "cd -" means to go back to whatever directory you were last in (has nothing to do with the structure of your directories.
 - Then 'clear' means wipe the terminal screen, 'pwd' says to print the current directory
 - the flags say to list all files starting with the directories in a long format. Symbols designate file types (-F) and file sizes are reported in a human readable format (-h)

alias ll='gls -alFh --group-directories-first'
- here, the gls is the GNU version of ls, so it's just saying to list all of the file types in long format, starting with the directories. 
- As with the previous two aliases, the -F flag says to tell me what type of file it is using symbols and -h means to list file sizes in a human readable format

## REFLECTION

Documenting all of the steps that I took throughout this assignment was made easier by having the README file 
open in BBedit. This allowed me to write in the document as I was actually carrying out the commands in my terminal. 
Keeping track of where I was (HPC vs local machine) was also very helpful, though I kept getting worried that 
I'd accidentally cause a merge conflict by going back and forth between the two computers. The primary challenge 
was working on a Mac, where some of the flags and command (e.g. 'ftp') have been discontinued for Macs. 
However, this was easy to fix using Homebrew. I also really enjoyed the exercise of translating the alias's. Translating code 
into sentences that I can understand really helped me to learn R language and it has also been very helpful when trying 
to learn shell commands and syntax. 


