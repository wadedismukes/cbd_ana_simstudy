#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=14-00:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 1 processor core(s) per node
#SBATCH --mem=16G   # maximum memory per node
#SBATCH --job-name="run-rev-all"
#SBATCH --mail-user=waded@iastate.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module load revbayes
sub=$1

cd $sub
sbatch --array=1-1000 --job-name=$sub /work/LAS/phylo-lab/waded/cbd_ana_simstudy/bash/array.sh $sub
cd ../..

