Class 7: Bash scripts, paths, and installing tools 
**was at ISAAH**

- instead of running the same 5-10 commands over and over again, you can wrap commands in scripts 
- a bash script is just a plain text file of commands.

### Tips for writing good scripts
- !/bin/bash = "shebang", tells the system which interpreter to use
	- *always the first line of the script*
	- this is the only time where the # will not get read as text 
- set -ueo pipefall = adds safety -u error on unset variable, -e exit on error, -o pipefall makes pipelines fail if any step fails 
- comments with #
- variable assignment: store values for reuse (fasta=$1) would capture argument 1 
- command invocation: the actual work, running tools, printing output, redirecting files 
- control flow (if, for): adds logic with if statements, loops and conditionals to automate decision making 
- exit 0 (optional): signals explicitly the end of a script. 

### Example script
```
#!/bin/bash
set -ueo pipefail
# assign first script parameter to the variable "name"
name=$1
# send "name" to stdout appended to "Hello, "
echo "Hello, $name!
```
Run the script like this
```
bash great.sh Alice
```

### File paths and $PATH
- By adding new programs to $PATH, you can run them without having to type the whole path
- $PATH is a list of directories your shell searches when you a type of a command
- if you want to add any directory to your $PATH environment variable, you can do 

```
export PATH=$PATH:/path/you/want/to/add
```

the above commands has created a new variable called path. But we already have the variable path
so this gets over written by the old version of itself ($PATH), then a semicolon, then the 
new file path that you want you shell to search through to find programs 

if you want to save that path, you'd need to add it to your ~/.bashrc file, otherwise gets deleted 
every time you close your terminal 

For instance, I added this path to my bashrc 

```
# open your .bashrc
nano /sciclone/home/iadanforth/.bashrc    
# in nano write"    
SHARED_DIR= sciclone/scr10/gz440"
# this created the saved new variable 'SHARED_DIR'. 
# echo $SHARED_DIR will repeat the path
```

In practice, if someone wants to run your script, they would need to have all of the programs your
code calls in their own $PATH. This is what tools like *DOCKER* are for. But they can make things 
more complicated. 
- "Docker just treats a 'symptom' of the root problem that it is difficult to write pipelines that will run 
	on unknown computers"
	
**it is very common for a script to install programs, document the installation and version, and 
then add the programs location ot the $PATH so it can easily be run**

### Making a script 

### Making a program "executible"