#!/bin/bash 
#PBS -N Boot_20 
#PBS -l nodes=1:ppn=2:geo2 
#PBS -q geo2 
#PBS -l walltime=12:00:0 
#PBS -e C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Boot\Input/LogFiles/Boot_20.err
#PBS -o C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Boot\Input/LogFiles/Boot_20.log

# go to directory
cd C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Boot\Input/Boot/

# load matlab
module load math/matlab/R2021a
# run matlab file
matlab -batch "preBoot('C:\Users\Matthias\Desktop\Program\Git\Programs_PhD\Boot\Input/Boot/Input/Boot_in_20.mat')"

