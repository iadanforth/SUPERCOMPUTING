# Assignment 02 
### Isabelle Danforth

 
## Task 1: Set up your semester workspace on the HPC
- Go into the supercomputer with the 'bora' alias (= ssh iadanforth@bora.sciclone.wm.edu)
- enter into your assignment_02 folder and create a new directory called "data"

```
bora
ls 
cd assignments/
ls
cd assignment_02
ls
mkdir data 
ls
```

## Task 2: Download files from NCBI via command-line FTP
- Go back to local machine 
- Use ftp command to connect to the NCBI FTP server 
- I did not know what the ftp command was, so I ran to view information on the command. and 'q' to exit.
```
man ftp
q
```
Now run the following to establish ftp access with this database in NCBI
```
ftp ftp.ncbi.nlm.nih.gov
```
I got an error message saying that the 'ftp' command was not found
ran 
```
brew install inetutils
```
to install ftp-style command
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
go back to the LOCAL computer
```
bye
```
check that you now have the two files that you wanted 
```
ls
```
- yay, they are there 
- now open FileZilla and follow prompts in assignment
- now upload the two files to REMOTE computer
- You can do this by going to where the files are stored on your local computer (left side of the 
FileZilla screen), clicking them both and dragging them to where you want them to appear 
on the REMOTE computer (inside of the 'data' folder nested within 'assignment_02)

### check the permissions of the files 
on your local computers terminal, type 
```
bora
cd SUPERCOMPUTING/assignments/assignment_02
ls
cd data
```
yes, the two files appear there!
now check their permissions
**note: ll is an alias for ls -alh*
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
it did! I think? Permisssions now read "-rw-r--r--."

## Task 4: Verify file integrity with md5sum
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

```
OUTPUT 1: e1b894042b53655594a1623a7e0bb63f  GCF_000005845.2_ASM584v2_genomic.fna.gz
OUTPUT 2: a93ff609c13f02dc9fc15255bc138401  GCF_000005845.2_ASM584v2_genomic.gff.gz

Proceeded to upload the script generated here to the supercomputer

## Task 5: Create useful Bash aliases



