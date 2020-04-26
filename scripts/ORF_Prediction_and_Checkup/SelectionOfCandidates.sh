#!/bin/bash


module load cufflinks
module load bedtools
module load gffread

#./SelectionOfCandidates.sh /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa ../../Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates/transcripts.gtf  ../../data/GRCm38_90_repeatmasker.bed


export refGTF=$1
export refSEQ=$2


cd FinalLncRNACandidates
cut -f1 ../transdecoder/transcripts.fasta.transdecoder.bed | sort -u >withORF.txt

awk '{print "transcript_id \""$1"\";"}' withORF.txt >tmp.txt

grep -v -Fwf tmp.txt ../transdecoder/transcripts.gtf | awk '{print $12}' | sort -u | sed 's/;//g' | sed 's/"//g' >noORF.txt

awk '{print "transcript_id \""$1"\";"}' noORF.txt | sort -u >bothset.txt

grep -Fwf bothset.txt ../transdecoder/transcripts.gtf >noORF.gtf

awk '{print "transcript_id \""$1"\";"}' ../transdecoder/BelowCurve.txt >tmp.txt

grep -Fwf tmp.txt ../transdecoder/transcripts.gtf >../transdecoder/BelowCurve.gtf

grep -E -- "antisense_RNA|3prime_overlapping_ncRNA|bidirectional_promoter_lncRNA|lincRNA|macro_lncRNA|non_coding|processed_transcript|sense_intronic|sense_overlapping|sense_intronic|TEC" ${refGTF} >GRCm38.90.longnoncodingRNAs.gtf


echo "noORF.gtf" >todo.txt
echo "../transdecoder/BelowCurve.gtf" >> todo.txt 


cuffmerge -p 10 --ref-gtf GRCm38.90.longnoncodingRNAs.gtf --ref-sequence ${refSEQ}  --min-isoform-fraction 0.2 todo.txt
gffread merged_asm/merged.gtf -g ${refSEQ} -w merged_asm/merged.fasta
rm tmp.txt
rm bothset.txt 
rm todo.txt

awk '{print $12}' merged_asm/merged.gtf | uniq -c | sed 's/"//g' | sed 's/;//g' | awk '{print $2"\t"$1}' >Transcript_ExonicInfo.txt
awk '{print "chr"$1"\t"$4"\t"$5"\t"$12"\t0\t"$7}' merged_asm/merged.gtf | sed 's/"//g' | sed 's/;//g' >merged_asm/mergedKnownAndNovelLncRNAs.bed
bedtools intersect -a merged_asm/mergedKnownAndNovelLncRNAs.bed -b ../transdecoder/repeats.bed -wo >Transcript_OverlapWithRepeats.txt 


