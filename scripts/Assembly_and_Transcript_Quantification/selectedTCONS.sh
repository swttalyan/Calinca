#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=20G

module load gffread
export mergedGTF=$1
export SEQ=$2


awk '{if($2>=200) print $1}' Output/TranscriptAssemblyAndabundanceEstimation/merged_asm/AllTranscripts_length.txt | sed 's/>//g' | sort -u >TCONSsleceted1.txt

grep -Fwf TCONSselected.txt TCONSsleceted1.txt | sort -u >transcripts.txt

rm TCONSselected.txt TCONSsleceted1.txt

awk '{print "transcript_id \""$1"\";"}' transcripts.txt >tmp.txt
grep -Fwf tmp.txt ${mergedGTF} >transcripts.gtf

rm tmp.txt
gffread transcripts.gtf -g ${SEQ} -w transcripts.fasta

mv transcripts.txt Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates/

mv transcripts.gtf Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates/

mv transcripts.fasta Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates/

