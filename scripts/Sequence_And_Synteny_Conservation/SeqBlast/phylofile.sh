#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=500G

perl human_mouse_file_forcyntenator.pl >New_Human_MouseCyntenator.blast
#perl perl.pl
#perl human_mouse_file_forcyntenator.pl >human_mouse.blast
