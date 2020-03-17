#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=4G

module load flexbar
flexbar -r $1 -p $2 -t $3 -n 10 -z GZ -m 20 -u 1 -q TAIL -qt 10 -k 248 -as "AGATCGGAAGAG" -qf sanger


 


