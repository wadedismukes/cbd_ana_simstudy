
#!/bin/bash
# load in modules
module load r
module load image-magick
module load git
module load gcc/10.2.0-zuvaafu
module load revbayes/1.1.1-wxcn3lf
# install relevant packages (locally)
Rscript R/install_packages.R
# run simulations and output DEC input files
Rscript R/simulation.R


# replace /data/ with the full directory so as not to confuse HPC
cd rev/
all=$(ls)
for sub in $all
do
    cd $sub
    find *.Rev | xargs sed -i "s/data\//\/work\/LAS\/phylo-lab\/waded\/cbd_ana_simstudy\/data\//g"
    find *.Rev | xargs sed -i "s/output\//\/work\/LAS\/phylo-lab\/waded\/cbd_ana_simstudy\/output\//g"
    cd ../
done