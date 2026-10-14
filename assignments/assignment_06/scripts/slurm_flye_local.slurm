#!/bin/bash
#SBATCH --job-name=flye_local_install
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=4 
#SBATCH --time=0-00:30:00 
#SBATCH --mem=120G 
#SBATCH --mail-type=FAIL,BEGIN,END 
#SBATCH --mail-user=iadanforth@wm.edu 
#SBATCH -o /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_06/slurm_logs/flye_manual_install_%j.out 
#SBATCH -e /sciclone/home/iadanforth/SUPERCOMPUTING/assignments/assignment_06/slurm_logs/flye_manual_install_%j.err 

cd ~/programs/
git clone https://github.com/fenderglass/Flye
cd Flye
make
echo 'export PATH="$HOME/programs/Flye/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
