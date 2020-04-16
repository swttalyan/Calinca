#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=50G

./../cyntenator -last -t "(human_pc_inputfile.txt mouse_pc_inputfile.txt)" -h blast human_mouse_allgenes_5hits.blast "(mouse_pc_inputfile.txt mouse_pc_inputfile.txt)" >pc_mouse_human_cyntenator_output.txt


#./../cyntenator -last -t "(human.txt mouse.txt)" -h phylo human_mouse_allgenes_5hits.blast "(house.txt mouse.txt)" >test2.txt
