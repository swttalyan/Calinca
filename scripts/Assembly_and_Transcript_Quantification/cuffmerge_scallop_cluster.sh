#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=20G

export GTF=$1
export SEQ=$2
export LAB=$3;

export LAB="merged_asm";

module load cufflinks

find .. -iname "scallop_outfile.gtf" > todo_cuffmerge.txt
cuffmerge -p 10 --ref-gtf ${GTF} --ref-sequence ${SEQ} --min-isoform-fraction 0.2 todo_cuffmerge.txt

cd ${LAB}
grep -v ' class_code "="' merged.gtf > relevant_new_tx.gtf
cat relevant_new_tx.gtf | perl -e 'while(<>){next unless /(TCONS\_\d+)/; print $1,"\t"; /class\_code\s\"(\w+)/; print $1,"\n";}' | sort -u | awk '{print $2;}' | sort | uniq -c > transcript_statistics.txt
gffread relevant_new_tx.gtf -g ${SEQ} -w relevant_new_tx.fa
gffread merged.gtf -g ${SEQ} -w merged.fa
cd ..

# sbatch ~/scripts/cufflinks_cluster.sh /data/projects/SYBACOL/mRNA_profiling_of_longevity_pathway_mutants_in_Celegans/Yidong_Germline_daf16/bam/N2_sorted.bam /data/projects/SYBACOL/annotation/Caenorhabditis_elegans.WBcel215.70_gffread_cuffcmp.combined.gtf /data/Genomes/C_elegans/Caenorhabditis_elegans.WBcel215.70_MaskFile.gtf N2
#/software/bedtools-2.20.1/bin/bedtools genomecov -ibam accepted_hit
#s.bam -bg -5 -g /data/Indices/STAR/Homo_sapiens/ENSEMBL.homo_sapiens.release-75/chrNameLength.txt > accepted_hits.bam_coverage 
