Class 5

- here is how you would transfer the file error.err from the scr10 shared by the class to your own scr10 

```
mv /sciclone/scr10/gzdata440/error.err ~/scr10
```

- this is where echo command might come in handy, tells you location of bash if you need to include this in a script for instance 

```
echo $BASH 
>/bin/bash
echo "I met your mom on $BORA"
> I met your mom on bora 
```

**the dollar sign gives you the value of a variable**

**be very careful with rm command*
- alias rm='rm -i' 
- this will force you to confirm when you want to remove 
- can add to .bash_profile

**shred** = gets rid of any information by rearranging all of the ones and zeros

# STREAMS

- *stdin* = standard input = 0
- *stdout* = standard output = 1 
- *stderr* = standard error = 2 
- in general, we write programs to take standard in, push out standard out and occasionally give error if there is an issue 

**REDIRECTING STREAM 1 (stdout)**
- echo "blank" # prints to screen
- echo "blank" > newfile.txt # creates a new file with this text 
- echo "blank" >> newfile.txt # appends to a file
- cat transcript.txt # print out the contents of the txt file on your screen 

**Redirecting STREAM 2 (stderr)**
- you just add 2> or 2>> to redirect the error 
- this is particularly useful since if you run stats on genomes or something, you dont 
  want this just spitting out on your screen. You want to just send it to file. So you can 
  get summary statistics and then include checkpoints
  
# PIPES
- The standard out from the stuff on the left and uses that as the input for the stuff on the right 

### E.G.: 

```
echo "hi mom" | wc -m 
```
this fed "hi mom" into the program "wc -m" which returns the number of characters 

```
echo "hi mom" | wc -m  >newfile.txt
```
this fills a newfile.txt with the number of characters in hi mom 

```
head seqs.fasta | wc -l
```

```
tail -n 4 seqs.fasta | tr 'T' 'U'
```
- this will take the first 4 lines of the file and convert the T TO the U 
- note that here, translate is only translating the T to the U in the first four lines ONLY

```
tail -n 4 seqs.fasta | tr 'T' 'U' > seqs_rna.fasta
```
can also add this if you want to save this information as a new file called seqs_rna.fast
if you don't do this, it will just print out

### how many lines are there in this seqs.fasta  

```
wc -l seqs.fasta 
```

### how many sequences are there?
- now what if we just want how many sequences are there? We need a way to count the lines that start with ">"
- we can do this with 'grep'
- syntax is grep "FOR SOME PATTERN" file name 
```
grep ">" seqs.fasta
```
- prints out all of the lines that start with > 

### get word count
- can then feed to wc -l to get word count
```
grep -c "^>" seqs.fasta
```

#### how many times does this sequence show up in the seqs.fasta file 
```{r}
cat seqs.fasta | grep "GCCCTTCGG"
```

- we see that there are two sequences that have this information
- so we can specify with the following

### what is the name of the last sequence in the file that contains "GCCCTTCGG" 
```
cat seqs.fasta | grep "GCCCTTCGG" | tail -n 1
```

# FOLLOW-UP ON REST OF THE LESSON (AFTER CLASS)

```
myname="Virus Queen"
echo $myname
> Virus Queen
```

- **brace expansion** of a variable is a way to make using variables more flexible and less ambiguous

E.g.
Let's say I have a sample named SAMPLEID = "pel-v1", and I want to create new variables based on this 
sample ID. These new ID's will be for the file name. I need to assign the following names to new variables 

pel-v1_fwd.fasta
pel-v1_rev.fasta
pel-v1.output
pel-v1.log
```
SAMPLEID="pel-v1"
echo ${SAMPLEID}_fwd.fasta
> pel-v1_fwd.fasta
```
- using this type of brace expansion is particularily useful if you are storing paths to directories or files as a variable
E.g.:
**I don't really understand this**

```
GDAL_DIR="/usr/lib/java/gdal"
GDAL_JAR="${GDAL_DIR}/gdal.jar"

OUT_DIR="/sciclone/home/gzahn/output"
echo "I am learning!" > ${OUT_DIR}/what_im_doing.txt
```

# SINGLE QUOTING vs DOUBLE QUOTING

- Single quoting = literal interpretation
- Double quoting = semi-literal interpretation

# Process vs Command Substitution
- Command substitution $(...) runs a command, captures its stdout, and drops it in place.
- Process substitution <(...) runs a command, gives you a temporary filename that refers to its output. Handy when a program expects file arguments.

```
echo "Today is $(date)"
> Today is Wed Sep 16 17:00:17 EDT 2026

wc -l <(date)
cat <(date)
echo <(date)
```

# Putting it together 
- I moved an IHNV sequence to my practice folder to use this .fa sequence 

```
MYFILE="HaVT_74_1974.fa" 
echo "There are $(grep -c "^>" $MYFILE) sequences in the file: $MYFILE"
There are 1 sequences in the file: HaVT_74_1974.fa
paste <(grep "^>" $MYFILE) <(grep -v "^>" $MYFILE)
```

# Useful tricks
- parameter expansion with pattern substitution:

```
SAMPLEID="SRR12338477"
FWD=${SAMPLEID}_fwd.fasta
REV=${FWD/fwd/rev} 
OUTFWD=${FWD/fasta/out}
OUTREV=${REV/fasta/out}
```
Bash lets you transform a variable as you expand it 
Syntax: ${variable/pattern/replacement}

The following will create three new directories (in my practice folder) and three new text files 
named sampleA, sampleB, sampleC, etc. 
```
mkdir test_{1..3}
touch sample{A,B}.txt
```







