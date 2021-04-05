#!/bin/bash
module purge
#module load gcc/10.2.0-zuvaafu
#module load revbayes/1.1.1-wxcn3lf
module load revbayes
# first arg is rb (i.e. revbayes)
rb=$1
# second arg is rev-scripts/ where all the rev-scripts are
dir=$2

cd $dir

all=$(ls *.Rev)

# go through the sub-directories of rev-scripts
for sub in $all
do
    sbatch --array=0-9 --job-name=$sub /work/LAS/phylo-lab/waded/cbd_ana_simstudy/bash/array_sub.sh $rb $sub
done
