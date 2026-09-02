# assignment_01_script

# from home directory
pwd # check your location
# access the "SUPERCOMPUTING" directory

cd SUPERCOMPUTING/

# create an assignment folder to store all assignments/projects
mkdir assignments

# enter this assignments folder
cd assignments/

# create directories for all 8 upcoming assignments (this was done in class)
mkdir assignment_01
mkdir assignment_02
mkdir assignment_03
mkdir assignment_04
mkdir assignment_05
mkdir assignment_06
mkdir assignment_07
mkdir assignment_08

# verify that it's all there
ls 

# enter assignment_01 to begin working on the first assignment
cd assignment_01

# create all of the subdirectories outlined in the assignment instructions
mkdir data scripts results docs config logs
cd data 

# create additional directories inside of "data" for raw versus clean data 
mkdir raw clean

# go back out of data to the "assignment_01" directory
cd .. 

# create a .md file for your essay and a .md file for the script containing these instructions
touch assignment_01_essay.md README.md

# the following commands are me moving in and out of my folders to create empty files in all of them 
ls
cd data

# I attempted to copy over a random csv of my own raw or clean data and encountered some issues 
# therefore, I just created empty csv's for now
cd raw
touch raw_data.csv
ls
cd ..
ls
cd clean
touch clean_data.csv
ls
cd ..
cd .. 
cd config
touch example.txt
cd .. 
cd docs 
touch notes.txt
cd ..
cd logs
touch logfile.log
cd ..
cd results
touch results_report.txt
cd ..
cd scripts
touch scripts.md

# proceeded to open my "assignment_01_essay.md" to write the essay 
cd .. 
ls
nano assignment_01_essay.md 
# wrote the essay in a txt file and copy pasted into the .md
# wrote some words
# checked the word count 
wc -w assignment_01_essay.md
# 981 words, all good

# then opened up the README.md to verify that that text written in BBEdit had correctly copied over







# assignment_01_script

# from home directory
pwd # check your location
# access the "SUPERCOMPUTING" directory

cd SUPERCOMPUTING/

# create an assignment folder to store all assignments/projects
mkdir assignments

# enter this assignments folder
cd assignments/

# create directories for all 8 upcoming assignments (this was done in class)
mkdir assignment_01
mkdir assignment_02
mkdir assignment_03
mkdir assignment_04
mkdir assignment_05
mkdir assignment_06
mkdir assignment_07
mkdir assignment_08

# verify that it's all there
ls 

# enter assignment_01 to begin working on the first assignment
cd assignment_01

# create all of the subdirectories outlined in the assignment instructions
mkdir data scripts results docs config logs
cd data 

# create additional directories inside of "data" for raw versus clean data 
mkdir raw clean

# go back out of data to the "assignment_01" directory
cd .. 

# create a .md file for your essay and a .md file for the script containing these instructions
touch assignment_01_essay.md README.md

# the following commands are me moving in and out of my folders to create empty files in all of them 
ls
cd data

# I attempted to copy over a random csv of my own raw or clean data and encountered some issues 
# therefore, I just created empty csv's for now
cd raw
touch raw_data.csv
ls
cd ..
ls
cd clean
touch clean_data.csv
ls
cd ..
cd .. 
cd config
touch example.txt
cd .. 
cd docs 
touch notes.txt
cd ..
cd logs
touch logfile.log
cd ..
cd results
touch results_report.txt
cd ..
cd scripts
touch scripts.md

# proceeded to open my "assignment_01_essay.md" to write the essay 
cd .. 
ls
nano assignment_01_essay.md 
# wrote the essay in a txt file and copy pasted into the .md
# wrote some words
# checked the word count 
wc -w assignment_01_essay.md
# 981 words, all good

# then opened up the README.md to verify that that text written in BBEdit had correctly copied over







