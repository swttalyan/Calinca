#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=20G

export mergedGTF=$1

awk '{if($2>=200) print $1}' Output/TranscriptAssemblyAndabundanceEstimation/merged_asm/AllTranscripts_length.txt | sed 's/>//g' | sort -u >TCONSsleceted1.txt
grep -Fwf TCONSselected.txt TCONSsleceted1.txt | sort -u >SelectedCandidates.txt
rm TCONSselected.txt TCONSsleceted1.txt
mv SelectedCandidates.txt Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates

awk '{print "transcript_id \""$1"\";"}' Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates/SelectedCandidates.txt >tmp.txt
grep -Fwf tmp.txt ${mergedGTF} >SelectedCandidates.gtf

rm tmp.txt
mv SelectedCandidates.gtf Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates/
