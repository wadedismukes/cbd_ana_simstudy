
#!/bin/bash
# load in modules
module load gcc/7.3.0-xegsmw4
module load r/4.0.3-py3-b6hdr5m
# install relevant packages (locally)
# Rscript R/install-packages.R


# run simulations and output DEC input files
Rscript R/simulation.R
