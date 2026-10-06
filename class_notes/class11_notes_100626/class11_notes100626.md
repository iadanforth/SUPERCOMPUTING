# Class 11 - Running a job on the supercomputer 
## 10/6/26
### LESSON 07 

*Slurm is basically the bouncer who coordinates the 

# Running a real pipeline on the HPC 
- If you just want to mess around with it, you can just take the first 4 lines of all of your files 
- you would do for loop


**this will run a for loop to create _test.fastq files that are just the first 4000 lines of 
all of the files**

```
for i in *.fast q do
IN=${i}; OUT={i/.fastq/_test.fastq};
head  -4000 $IN >> $OUT;
done 
```

## SLURM SCRIPTS
- This is what you submit to the cluster 
- SLURM HEADER: Copy past situation
- the #SBATCH is NOT A COMMENT LINE!!! If the # is followed by SBATCH, it will accept this 
  as a command
- YOU CANNOT PUT COMMENTS IN THIS!!! It's just one giant chunk of text 
- all slurm commands start with s
- when estimating the amount of time for a job -- not always better to ask for the max time (you do get cut off). 
  but it takes longer for you to get in line if you ask for more time. It also takes more time if you ask for 
  -- exclusive -- 
	- TO ESTIMATE TIME 
		- run for 4000 lines, then run for 8000 lines, assume linear relationship and plan
		
- asking for more than 64 cores is not really efficient (SATURATING RELATIONSHIP)

- GPU vs CPU
 	- GPU: exponentially more calculations but all very small (initially made for video games)
 	   - less precision, more speed 
 	   - good for parallel jobs (splits up jobs across a million tiny computers)
 	   - AI, neural networks, black holes 
 	- CPU: this is *serial jobs*, doing a step by step process 
 		- metagenomics are CPU 

## SLURM HEADINGS
```
#!/bin/bash
#SBATCH --jobname=gulftest
#SBATCH --nodes=1                 #-- i just want to use one node --#
#SBATCH --ntasks=1                #-- in this class, will mostly be 1 --#
#SBATCH -- cpus-per-task=64       #-- 64 cpu's only works for gulf, over 64 CPU's is not going to help very much --#
#SBATCH --time=2-00:00:00 		  #-- max allowed is 3 days, guessing the amount of time that you need is an art --#
#SBATCH mem=980G 				  
#SBATCH --exclusive               #-- means that no one else can use your node: good for preventing others from stacking on your job --#
#SBATCH -C gz #lab nodes
#SBATCH --mail-type=FAIL, BEGIN, END #-- this is how you get notified --#
#SBATCH --mail-user=gzahn.wm.edu #-- this is the email to send to notification to !!!CHANGE TO YOUR EMAIL!!! --# 
#SBATCH -o /sciclone/home/gzahn/logs/test_%j.out #-- Slurm sends the output here --#
#SBATCH -o /sciclone/home/gzahn/logs/test_%j.err #-- _%j is the job number --#

# WHEN A JOB FAILS YOU NEED TO GO TO THE OUT AND ERROR MESSAGES TO SEE WHAT WENT WRONG
# Some programs send their outputs to the error files, so you should check both for what went wrong 
```

## INFO ON SLURM 
```
# this 'sinfo' command can be run from supercomputer
sinfo
```
** this is the info that prints back **
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
batch*       up 3-00:00:00      2   resv bo[11,23]
batch*       up 3-00:00:00      6    mix bo[06-07,19,22,28,34]
batch*       up 3-00:00:00     31  alloc bo[03-05,12-14,16-18,20-21,24-26,29-31,33,37,43,45-55]
        # can run up to 3 days        # so 31 nodes are currently in use
batch*       up 3-00:00:00      6   idle bo[08,10,15,27,42,44]
hima         up 3-00:00:00      4    mix hi[01-02,04-05]
hima         up 3-00:00:00      3  alloc hi[03,06-07]

```
scontrol show node

scontrol show node | grep "CPUTot=64"
# so we used grep to see if there is a node with CPU available of 64
# we see that there are none 
# this is because we are on Bora but only Gulf has this quantity of CPUs 
# so we would need to log in to Gulf 
# can just change the login to gulf (remember that we made a Bora alias)
# YOU MUST LOG IN TO THE LOGIN NODE THAT CAN SUBMIT A JOB TO THE COMPUTER THAT YOU NEED 
# You can access GPU's through Hema node from Bora 
# but higher CPU jobs will require Kuro or Gulf 
```
**you get info like this for each node (this is just an excerpt)*

```
NodeName=bo28 Arch=x86_64 CoresPerSocket=10 
   CPUAlloc=1 CPUEfctv=20 CPUTot=20 CPULoad=1.00
   # CPUTot=20 --> but we're asking for 64
   # SLURM searches through all of the nodes that it can see and 
   # looks for one that has 64 nodes 
   AvailableFeatures=bora,bo
   ActiveFeatures=bora,bo
   Gres=(null)
   NodeAddr=bo28 NodeHostName=bo28 Version=23.11.9
   OS=Linux 5.14.0-687.15.1.el9_8.x86_64 #1 SMP PREEMPT_DYNAMIC Thu Jun 11 16:33:25 UTC 2026 
   RealMemory=128168 AllocMem=65536 FreeMem=1852 Sockets=2 Boards=1
   State=MIXED ThreadsPerCore=1 TmpDisk=0 Weight=1 Owner=eilookeke(272075) MCS_label=N/A
   Partitions=batch 
   BootTime=2026-07-21T08:55:39 SlurmdStartTime=2026-10-04T00:00:03
   LastBusyTime=2026-10-05T14:36:34 ResumeAfterTime=None
   CfgTRES=cpu=20,mem=128168M,billing=20
   AllocTRES=cpu=1,mem=64G
   CapWatts=n/a
   CurrentWatts=0 AveWatts=0
   ExtSensorsJoules=n/a ExtSensorsWatts=0 ExtSensorsTemp=n/a
```

## SLURM TEMPLATE FOR BORA
```
#!/bin/bash
#SBATCH --job-name=JOBNAME
#SBATCH --nodes=1 # how many physical machines in the cluster
#SBATCH --ntasks=1 # how many separate 'tasks' (stick to 1)
#SBATCH --cpus-per-task=20 # how many cores (bora max is 20)
#SBATCH --time=2-00:00:00 # d-hh:mm:ss or just No. of minutes
#SBATCH --mem=120G # how much physical memory (all by default)
#SBATCH --mail-type=FAIL,BEGIN,END # when to email you
#SBATCH --mail-user=YOU@wm.edu # who to email
#SBATCH -o JOBNAME_%j.out #STDOUT to file (%j is jobID)
		# if you don't specify the path here, the job output will just go to where 
		# your job script is (which is probably not ideal because it's just a folder in home 
		# called job)
#SBATCH -e JOBNAME_%j.err #STDERR to file (%j is jobID)
module load whatever_modules_you_need #set up environment
echo "Hello world!" # code to run (could be a .sh script or series)
```

## SUBMITTING A JOB
```
# from home, create a slurm script 
nano testjob.slurm 
```

print the following into testjob.slurm

```
cat testjob.slurm
sbatch testjob.slurm 
sacct
cat test_hello_542323.err
cat test_hello__542323.out
# in this case, we did not specify a path for .out and .err, so the .err and .out 
# just got saved to my home directory, where I created the slurm script 
```


```
# this translates tab into space 
scontrol show node | grep "CPUTot" | tr "\t" " "

# sed = streaming editor 
scontrol show node | grep "CPUTot" | sed 
```

## STREAMING EDITOR
 - like grep but will edit your file line by line 
 - we give it an expression
 
```
scontrol show node | grep "CPUTot" | sed 's/ /:/g'
# s means search and replace mode
# i'm going to search for a space and replace it with a colon
# and I'm going to do that globally, not just the first line 

scontrol show node | grep "CPUTot" | sed 's/   //g'
# now turn every instance of THREE spaces into nothing 

scontrol show node | grep "CPUTot" | sed 's/   //g' | cut -d " " -f 3 
# print out all nodes and their CPUTot

scontrol show node | grep "CPUTot" | sed 's/   //g' | cut -d " " -f 3 | sort -u
# print out the unique nodes and their CPUTot

# what if i don't know how many spaces there are but you want to know if there is more than one space
scontrol show node | grep "CPUTot" | sed 's/  *//g'
# get rid of all spaces in there 

scontrol show node | grep "CPUTot" | sed 's/  *//'
# only removes first instance 
```

## WRITING A REAL SLURM SCRIPT AND CALLING A PROGRAM
```
# FROM HOME 
sq 
# everyone who is waiting in line 
```

JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          541758_0     batch   piplus  jgiroux  R   17:00:04      1 bo31
          # job is 17hrs in 
          541758_1     batch   piplus  jgiroux  R   17:00:04      1 bo12
          541758_2     batch   piplus  jgiroux  R   17:00:04      1 bo12
          541758_3     batch   piplus  jgiroux  R   17:00:04      1 bo43
          541758_4     batch   piplus  jgiroux  R   17:00:04      1 bo43
          541758_5     batch   piplus  jgiroux  R   17:00:04      1 bo03


# MISCELLANEOUS 
```
less [file name]
```