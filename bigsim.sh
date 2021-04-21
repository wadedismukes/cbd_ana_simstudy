#!/bin/bash

#SBATCH --time=24:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=36   # 36 processor core(s) per node 
#SBATCH --mem=32G   # maximum memory per node
#SBATCH --job-name="simsetup"
#SBATCH --mail-user=waded@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL


# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
sh bash/setup.sh
