# Assignment 03 
## 091626
### Isabelle Danforth

## Task 1: Navigate to assignment_03 directory and set it up
```
pwd
cd ~/SUPERCOMPUTING/assignments/assignment_02
ls
touch README_assignment03.md
mkdir data
```


## Task 2: Download the fasta sequence file using wget
```
cd data
wget https://gzahn.github.io/data/GCF_000001735.4_TAIR10.1_genomic.fna.gz
ls
gunzip GCF_000001735.4_TAIR10.1_genomic.fna.gz
```

Then created a variable for this .gz. I realize that we did not go over this in class,
but noticed that it had been discussed later in lesson 03.
```
MYFILE="GCF_000001735.4_TAIR10.1_genomic.fna"
echo $MYFILE
```

## Task 3: Use Unix tools to explore file contents 

1. How many sequences are in the FASTA file?
```
echo "There are $(grep -c "^>" $MYFILE) sequences in the file:$MYFILE"
```
**ANSWER**: There are 7 sequences 

2. What is the total number of nucleotides (not including header lines or newlines)? 
```
grep -v '^>' $MYFILE | tr -d '\n' | wc -c > q2.txt
nano q2.txt
```
*EXPLANATION*
- grep -v '^>' = print out every line except header lines starting with > 
- tr -d '\n' = removes all newline characters 
- wc -c = already know, counts bytes 
- then sent the output of this command to a text file just for practice
**ANSWER**:  119,668,634

3. How many total lines are in the file?
```
echo "There are $(wc -l $MYFILE) lines in the file: $MYFILE"
```
**ANSWER**: 14

4. How many header lines contain the word "mitochondrion"?
- first filter the file to only contain header lines
- then count the number of times you see "mitochondrion"
```
grep "^>" $MYFILE | grep -c "mitochondrion"
```
**ANSWER**: 1

5. How many header lines contain the word "chromosome"? (answer=5)
- first, filter the file to only contain header lines
- then count up the number of lines that contain the word chromosome
```
grep "^>" $MYFILE | grep -c "chromosome"
```
**ANSWER**: 5

6. How many nucleotides are in each of the first 3 chromosome sequences? 
- I struggled with this one and asked Claude AI how it would approach this. 
  It recommended using 'awk' or 'sed'. We had not discussed these in class so I tried 
  to find a work around 
- Decided to define the starts and ends of each sequence 
- I was then thinking that if I can create new fasta files for each chromosome, 
  maybe it would be easier to get the word count

Specify where Chromosome 1 sequence ends and then save it as a new file 
```
END_LINE=$(grep -n "^>" $MYFILE | head -2 | tail -1 | cut -d: -f1)
head -n $((END_LINE - 1)) $MYFILE > chromosome1.fasta
grep -v '^>' chromosome1.fasta | wc -c
```
repeat for chromosome 2 
```
START_LINE=$(grep -n "^>" $MYFILE | head -2 | tail -1 | cut -d: -f1)
END_LINE2=$(grep -n "^>" $MYFILE | head -3 | tail -1 | cut -d: -f1)
tail -n +$START_LINE $MYFILE | head -n $((END_LINE2 - START_LINE)) > chromosome2.fasta
grep -v '^>' chromosome2.fasta | wc -c
```
and for chromosome 3 
```
START_LINE2=$(grep -n "^>" $MYFILE | head -3 | tail -1 | cut -d: -f1)
END_LINE3=$(grep -n "^>" $MYFILE | head -4 | tail -1 | cut -d: -f1)
tail -n +$START_LINE2 $MYFILE | head -n $((END_LINE3 - START_LINE2)) > chromosome3.fasta
grep -v '^>' chromosome3.fasta | wc -c
```

**ANSWER**: 30427672, 19698290, 23459831


7. How many nucleotides are in the sequence for 'chromosome 5'? 
Followed the same process as in (6)

```
START_LINE5=$(grep -n "^>" $MYFILE | head -5 | tail -1 | cut -d: -f1)
END_LINE5=$(grep -n "^>" $MYFILE | head -6 | tail -1 | cut -d: -f1)
tail -n +$START_LINE5 $MYFILE | head -n $((END_LINE5 - START_LINE5)) > chromosome5.fasta
grep -v '^>' chromosome5.fasta | wc -c
```

26975503
Then used awk (recommended by Claude), just to see how this works and if I would get 
the same answer. I don't think that we have discussed 'awk' yet, but I saw it listed in 
the "bash_programs_and_syntax" document. 

```
awk '/^>.*chromosome 5/{flag=1; next} /^>/{flag=0} flag' $MYFILE | wc -c
```
26975503

- awk seems like it's similar to the "if then" statements that I'm used to in R. 
- In this case, the goal is to only apply the word count to the sequence between the header containing the word
  "chromosome 5" and the next header where there is a ">"
- /^>.*chromosome 5/{flag=1; next} - this says to turn on the flag IF the line starts with a ">" AND contains 
  the word "chromosome 5". We know that there is only one sequence in this file with the word "chromosome 5" 
- /^>/{flag=0} - turn the flag off once you hit a new line that starts with a ">" 
- then just pipe to wc -c as before


**ANSWER**: 26,975,503

8. How many sequences contain "AAAAAAAAAAAAAAAA"? 

```
grep -c "AAAAAAAAAAAAAAAA" $MYFILE
```
This doesn't necessarily say that one sequence as this pattern, but that it appears 1 time
(which would imply that it appears in one sequence only)
**ANSWER** = 1


9. If you were to sort the sequences alphabetically, which sequence (header) would be first in that list? (answer=>NC_000932.1...)
We did not discuss "sort" in class, but I saw it listed in the "bash_programs_and_syntax" document and figured that it probably sorted things.
Also tried a few of the flags that seemed relevant. 
```
man sort
grep '^>' $MYFILE | sort
grep '^>' $MYFILE | sort -r
grep '^>' $MYFILE | sort -n
```
**ANSWER** = NC_000932.1 Arabidopsis thaliana chloroplast, complete genome

10. How would you make a new tab-separated version of this file, where the first column is the headers and the second column are the associated sequences? (show the command(s))
Despite my efforts, I could not figure out how to do this without the help of Claude. This is the command that it suggested and my interpretation of each part.

```
awk '/^>/{if (seq) print h"\t"seq; h=substr($0,2); seq=""; next} {seq = seq $0} END{print h"\t"seq}' $MYFILE > GCF_seqs.tsv
nano GCF_seqs.tsv
```
*EXPLANATION*
- My understanding is that the reason why you need 'awk' for this task is that the program can manipulate text, columns, and data (wich 'grep' cannot do)
- h (column 1) is holding the header text and seq (column 2) holds the sequence text 
- "\t" means insert a tab here
- h"\t"seq means "take the value of h, stick a tab onto the end of it, then stick the value of seq onto the end of that (as string)
- /^>/{____} - first piece only applies to headers, where awk finds a '>' -> so this would apply to the first column 
- Inside of the brackets: 
	- if (seq) print h"\t"seq: first check if seq already has content from a previous record. If the answer is yes, then print out that previous header and sequence tab separated.
	- h=substr($0,2): h stands for header (could have just written header). This says to make the header the current line, but to remove the first character (which i think is >). 
	  That is what the substr($0,2) does, it says to start at position 2, meaning drop the > 
	- seq="": for the next line, start a new record 
	- next: skip the rest of the script and jump to next line (so that you're not reading the nucleotides I think)
- the second brackets ({seq = seq $0}) are applying to everything that isn't a header 
	- so this adds the nucleotides in a string with no line breaks 
- END{print h"\t"seq}': at the end, there is no new header to read, so END terminates this 
- then you just say to apply this to $MYFILE 
- and generate a new .tsv file 
	
  

### Task 4: Verify that the README correctly follows the process used



### Task 5: Reflection
After all of your documentation for doing the assignment, at the bottom of your README.md file, write up a 300–600 word reflection on:
Your approach and what you learned
Any command-line tools that surprised or frustrated you
Why these kinds of skills are essential in computational work
(Optional) How your solution could be automated in the future

For this assignment and all preceding ones, my process has been to create a .md file in
the proper directory and to then open it in BBedit. I also have a .md file of my 
class notes, previous assignments, and miscellaneous practice open at the same time so that
I can refer back to these when needed. That way, I can have my terminal open, but also easily
move back and forth between different .md's as I am working through the assignment. This 
also makes it much easier to copy and paste each line of code that I write back into the .md, 
or to play with it in the .md if I am unsure about the syntax and want to copy and paste from
another document. 

I did not find the first few exercises to be too challenging as we 
had done very similar things in class. However, by the 6th exercise I had to put some more 
thought into how I should approach this. What I found most useful was to think logically
about what processes have to happen in order for the task to be accomplished and to break 
them into pieces. For instance, if I want my friend to make me a sandwich, I would tell them 
"go to the fridge", "find the bread", "trim the crusts", etc. Similarly, for more complex 
exercises, I found it useful to think of it as telling the computer, "go find all of the headers 
in this file by finding places where there is a >". Then, "find every place where there is the word 
chromosome". Then, "count how many times this word appears". When I was not sure how to 
approach the exercise, it helped to troubleshoot each part of the process. I could run just one 
command to see what that did. If it did what I wanted, I could try adding the next one and so on.  
I also enjoyed having to think a bit creatively about how I would translate what I want and which ways might have limitations. 
For example, in exercise 6, I used the order of the sequences to pull out each sequence. But 
my approach would not work the same if someone else's file did not have the sequences in order from 
chromosome 1 to chromosome 5. 

Many of these tools are very different from the ones that I am used to using in R, while others
seem very similar. In my experience, R is not very good at handling any text files, but excels at dealing with
tabular data. It seems like tools like 'grep' or 'awk' are particularly well-suited to 
navigating .fasta files where information is presented as a sequence of letters, whereas I would 
struggle to do the same things in R. Being comfortable using these programs is evidently critical
to computational work to increase reproducibility and speed. I could have completed most of 
these exercises by copy-pasting the sequences into Word and highlighting the regions where 
I wanted to know the nucleotide count. However, this would have taken much longer and would not 
scale well to handling thousands of sequences that are much longer than these ones. In fact,
the dinoflagellates that I'm interested in have genomes so enormous that virtually no 
whole genomes exist. 

By naming the .fasta file $MYFILE, I thought that this was at least a step in the right direction
towards making my process more automated. Anyone could simply set the variable $MYFILE as their 
own .fasta file and then run my script. However, there are a few places where this would break down. 
In exercise 6, I could have used 'awk', but wasn't sure if this was allowed since it had 
not explicitly been discussed in class. Therefore, I thought that if I could split the fasta 
file into new files, each containing the sequence of interest, I could accomplish the same thing 
without 'awk'. But in order for this process to be automated, it would have been better to use 'awk'
as this does not rely on the file having the same structure as my file. I have also used functions and 
for loops in R to automate scripts, though I am not sure if there are similar tools available in this case. 


