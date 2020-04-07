#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=20G

export GTF=$1
export SEQ=$2


export LAB="merged_asm";

module load cufflinks
module load gffread

find .. -iname "stringtieB_outfile.gtf" > todo_cuffmerge.txt

cuffmerge -p 10 --ref-gtf ${GTF} --ref-sequence ${SEQ} --min-isoform-fraction 0.2 todo_cuffmerge.txt


cd ${LAB}
grep -v ' class_code "="' merged.gtf > relevant_new_tx.gtf
cat relevant_new_tx.gtf | perl -e 'while(<>){next unless /(TCONS\_\d+)/; print $1,"\t"; /class\_code\s\"(\w+)/; print $1,"\n";}' | sort -u | awk '{print $2;}' | sort | uniq -c > transcript_statistics.txt
gffread merged.gtf -g ${SEQ} -w merged.fa

cd ..
mv merged_asm/ Output/TranscriptAssemblyAndabundanceEstimation/

awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' Output/TranscriptAssemblyAndabundanceEstimation/merged_asm/merged.fa | awk 'ORS=NR%2?" ":"\n"' >Output/TranscriptAssemblyAndabundanceEstimation/merged_asm/AllTranscripts_length.txt
 
