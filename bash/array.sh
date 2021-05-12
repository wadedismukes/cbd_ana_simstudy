#!/bin/bash

#SBATCH --time=14-00:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # 16 processor core(s) per node
#SBATCH --mem=16G   # maximum memory per node
#SBATCH --job-name="run-rev-all"
#SBATCH --mail-user=waded@iastate.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
module load revbayes
rb run_epoch.${SLURM_ARRAY_TASK_ID}.Rev
