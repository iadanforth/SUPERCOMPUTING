# Class 6 Notes
Can refer to lesson03 for all of this 

### first access the file and name it my file 
```
MYFILE="/sciclone/scr10/gzdata440/Fungal_seqs.fasta"
```

get the number of sequences (2034) and send it to a new file 
```
echo "There are $(grep -c "^>" $MYFILE) sequences in the file:$MYFILE" > seq_count.txt
```

copy the file and put it in your current directory
```
cp /sciclone/scr10/gzdata440/Fungal_seq.fasta ./
```

```
cat Fungal_Seqs.fasta | grep "N" | grep -v "^>"
cat Fungal_Seqs.fasta | grep "N" | grep -v "^>.*A$"
```

. = any character
* = means zero or infinite of anything

# BASH VARIABLE
- will get deleted as soon as you get out of your terminal

### open .bashrc from supercomputer
```
nano /sciclone/home/iadanforth/.bashrc       
> in nano write" SHARED_DIR= sciclone/scr10/gz440"
```
now you can access the shared directory as follows 
```
cd $SHARED_DIR/
# get out with 
cd ~ 
# takes you back to your bora
```

### better way to do that is to use curly braces
We want to create four new file names that all have the same SAMPLEID in the beginning but then different ends
Curly braces protext the name of the variable so that the dollar sign can expand the name of any variable 

```
SAMPLEID = "pel-v"
echo ${SAMPLEID}_fwd.fasta
```
this approach is often used to save file paths 
e.g.
```
GDAL_DIR="/usr/lib/java/gdal"
GDAL_JAR="${GDAL_DIR}/gdal.jar"
```

# QUOTING 
```
"$HOME"
# double quotes are semi-literal
# so this returns the full file path 
# double quotes allow expansion

'$HOME'
# treats it as text and thinks that you literally want the quote in there 
# for useing grep and sed a lot of times you do want literal interpretation, so you might 
# used ''
```

# Process and command substitution
```
echo "Today is $(date)"
# returns: Today is Wed Sep 16 17:00:17 EDT 2026

echo 'Today is $(date)'
# returns "$(date)"
```
This is handy because we can make the code document itself with that line for when 
something was run 

```
echo "Today is <(date)"
# returns "Today is <(date)"

echo <(date)
# will always return /dev/fd/63
# this is an imaginary file 
```
- $ = evaluates into a string
- < = "evaluate this expression and send it to an imaginary file" - evaluates into an imaginary file
- so different programs will want you to use $ vs < 
- Many programs require a file as input (not keyboard inputs). Maybe you don't want to write it to disk
  because that takes time. So we can **make an imaginary file and have that program read the file**. If you want
  to access it again, you could theoretically write that file to disk.
- **if you have a huge METAGENOMIC dataset, and you're not using process substitution, YOU ARE WASTING TIME!!!** 

```
wc "hello"
# returns error (wants a file)
wc <(echo hello)
# returns number of bytes, chrs, lines
```

```
paste <(echo hello) <(echo "you suck")
# returns "hello you suck" - so it puts a tab delimiter between hello and you suck 
```

```
cat <(date)
# returns "Thu Sep 17 10:33:15 AM EDT 2026"
# this is because cat expects a file
echo <(date)
# returns /dev/fd/63
# this is because echo expects a string 
```

```
SAMPLEID="SRR12338477"
FWD=${SAMPLEID}_fwd.fasta
echo $FWD
REV=${FWD/fwd/rev} 
# look for the word 'fwd' and replace it with 'rev'
# echo $REV
OUTFWD=${FWD/fasta/out}
# take the current value of FWD, looks for the word fasta, and replaces it with the word out
OUTREV=${REV/fasta/out}
# takes the current value of REV, looks for the word fasta, and replaced it with the word out 
```
- so you would use this so that the program that your running gets instructions to output files in the file name format
- SYNTAX: **${variable/pattern/replacement}** 

VAR1="file_A_A_1.txt"
echo $VAR1
echo ${VAR1/A/B} # find first A and replace to B
echo ${VAR1//A/B} # find all A's and replace with B 
VAR3=$(echo ${VAR1//A/B})
# this would make file_B_B_1.txt as VAR3
# it helps to read these commands from the inside out 



# MY QUESTIONS
1. What is the difference between files being in RAM vs DISK
