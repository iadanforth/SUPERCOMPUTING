# Class 2 Notes - 09/03/26

1. We signed up for HPC access 
https://www.wm.edu/offices/it/services/researchcomputing/acctreq/

2. Useful resource for knowing the different CLUSTERS available through WM HPC
https://www.wm.edu/offices/it/services/researchcomputing/atwm/systemarchitecture/nodes/


# Intro to supercomputing
- Multi-node parallel clusters: talk to one another, so you could take your job and spread them across the nodes of the cluster.
	- Special case scenario, means that you need to be running code that runs multi-level parallelization 
- Serial clusters: one set of calculations in order 
- Main campus Kubernetes cluster
- **node** = kuro, contains a specific number of cores per node 
- **core** = number of chips. So we essentially run several computers on one computer. On the HPC, there are about 32 cores per node 
	- 4 cores tends tend to be 4x as fast 
	- so 32 cores is 32 times faster 
	- the Kuro cluster is commonly used by the physics department 
	
## Femto Core
- 32 cores

## Bora Core
- *this is the one that we will be using*
- 20 cores
- 120 GB RAM

## Hima Core
- Only 7 
- Have GPUs to run neural networks 
- 32 CPU cores 
- **GPU** = "graphical processing unit"
- **CPU** = "central/computational processing unit"
- **NPU** = neural processing unit
- Each of these differ based on the structure of the chip 

## Slurm is like a traffic cop
- it prioritizes smaller shorter tasks (like a grocery store check out line)

## Logging into Bora 
- Max is 20 people 
- DO NOT DO ANY WORK ON THE LOGIN NODE 
- Login node is good for running your fake data to test things out. 
- It's like a sandbox 
- ***DO NOT RUN JOBS THERE***

## For accessing the supercomputer 
```
ssh iadanforth@bora.ciclone.wm.edu
```

- root are the 5 people listed on the WM web page 
- we have 50 GB 
	- recommended to store local software 
	
how to move out of the current folder and into one right before it 


# Miscellaneous notes
how to move out of the current folder and into one right before it 
```
../path
```

to install 'tree' on MacOS, allowing you to view you folders in a more intuitive way 
```
brew install tree
tree
```

