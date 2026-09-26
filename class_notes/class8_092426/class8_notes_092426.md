Class 8 -- Using tools in practice 

# Topics
- Parameter expansion how to and cheat sheet 
	- pattern replacement 
	- substring removal/trimming
	- substring extraction
- for loop structure
- creating a script and applying it to several fastq files in a for loop

-------------------------------------------------------------------------------

1. log in to super computer

2. move the fasta file to your directory 
```
cd /sciclone/scr10/gzdata440/lesson_05
cp -r * ~/SUPERCOMPUTING/class_notes/class8_092426/
cd $HOME/SUPERCOMPUTING/class_notes
mkdir class8_092426
mv data interleave_chop.sh * ~/SUPERCOMPUTING/class_notes/class8_092426
```



inspect the first four lines of one of the files to see what is in there 
- now have a folder called 'data' inside class8_092426
- run the following code to print the first four lines of one of the files to the screen 
```
head -n 4 S092_S82_interleaved_chop_101.fastq
```

I then had Claude make me a python script for generating a table of quality scores. 
I saved this in 'programs' and created a variable in my .bashrc to call it from anywhere 
```
QUAL=$(sed -n '4p' S096_S38_interleaved_chop_70.fastq)
python3 "$QUAL_TBL" "$QUAL"
```

There's also a script that Geoff made in the class8_notes folder called 
'interleave_chop.sh'. This script takes paired fwd and rev fastq files, chops N reads off 
the 3' end, and interleaves the fwd and rev reads into a single output file.

The script takes 4 positional arguments. The forward reads (denoted R1 in the fastq files)
, the paired reverse reads (R2), the name of an output file, and the number of nucleotides to chop off of the 3' end of the reads. It can handle regular or gzipped file formats.

Usage: <R1.fastq[.gz]> <R2.fastq[.gz]> <out.fastq[.gz]> <N_to_chop>

Example:

./interleave_chop.sh S090_S9_L001_R1_sample.fastq S090_S9_L001_R2_sample.fastq S090_out.fastq 200

**I created a variable called 'INTERLEAVE_CHOP'. To run the script, do the following**
```
"$INTERLEAVE_CHOP" S090_S9_L001_R1_sample.fastq S090_S9_L001_R2_sample.fastq S090_out.fastq 200
```
this will create a file called S090_out.fastq that can now be inspected 

## Parameter expansion
- How can we run through both the forward and the reverse primers 
```
for file in *_R1_sample.fastq; do 
$INTERLEAVE_CHOP $file; 
done
```
- this just returns the usage examples?
- interleave_chop.sh requires that we also pass it the paired reverse filenames, as well as an output file.
- so we need "parameter expansion"
- The idea is that when we call any variable with ${VARIABLE}, we can do a little editing of the variable name along the way.
- The simplest way of doing this is a "search and replace" **${yourvariable/search/replace}**

#### Run the following:
```
#create a new variable
VAR="myfile_1.txt"
# during expansion, replace 1 with 2
echo ${VAR} ${VAR/1/2} ${VAR/_1.txt/}_output.log
```
- What did that do? How did it work? Can you see the patterns?
- You can do this inside a for-loop as well:

```
# this won't run. just an illustration
for FWD in *_1.txt # begin for-loop on all files that end in `_1.txt`
do # start loop commands
REV=${FWD/1/2} 
# create another variable called REV
some_program.sh $FWD $REV 
# giving fwd and rev filenames to the program
done
```

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

## Practice with parameter expansion and explanations
```
VAR="S090_S9_L001_R1_sample.fastq"

######### SUBSTRING REMOVAL/TRIMMING ############
echo ${VAR%_*}
# strips the shortest possible match of "_*" from the end. 
# finds the LAST underscore in the string 
# and removes from there to the end 
> S090_S9_L001_R1

echo ${VAR%%_*}
# removes the longest possible match of _* from the end 
# finds the FIRST underscore and removes everything after it
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
- the % and %% remove a suffix, but % removes the shortest matching suffix, the %% 
%% removes the longest matching suffix 


# For loops and parameter expansion 
Write a for loop that runs interleave_chop.sh on ALL of the fastq file pairs 
The output files should be based on the inputs 

First, remove all files with interleaved_chop (pretty sure this code was run
before I had downloaded all the files to my account - we don't want them because we're about 
to make them)
```
rm *_interleaved_chop_*.fastq

# leaves us with just the .fastq files
# rememebr that R1 = forward (FWD)
# R2 = reverse (REV)
```
```
for FWD in *_R1_*.fastq; do 
# for all sequences with _R1 (meaning all of the forwards), do the following
    REV="${FWD/_R1_/_R2_}"
    # rename all files with R2 for reverse

    SAMPLE="${FWD%%_*}"
    # INPUT = SAMPLE
    # ALL forward sequences - take the SAMPLE ID NAME (the part coming before the first _)
    OUT="${SAMPLE}_interleaved_chop.fastq"
    # OUT = SAMPLE (named in line above), with interleaved name on end 
    
    $INTERLEAVE_CHOP "$FWD" "$REV" "$OUT" 100
    # apply script
done
```

