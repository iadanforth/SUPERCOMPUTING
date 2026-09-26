# Practice Lesson 04 

- download and unzip the following zip files 

```
wget http://gzahn.github.io/binf-data-skills/Data/Chapter_3_Practice_Files.zip
unzip Chapter_3_Practice_Files.zip
cd Chapter_3_Practice_Files
```

## Task 1 - take A.txt and B.txt and combine them into two new columns in the file C.txt
```
paste A.txt B.txt > C.txt
nano C.txt
```

## Task 2: Combine the words that begin with either B or E (case insensitive) from words.txt
with the first 6 lines of the new C.txt file you just created 

```
grep -i "[be]" words.txt
# this greps for B or E and b or e (case insensitive)
paste C.txt words.txt
head -n 6 C.txt | paste C.
```
```