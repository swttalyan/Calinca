#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=40G

export BAM=$1
export GTF=$2
export LAB=$3
export LIBRARY_TYPE=$4

module load cufflinks

cuffquant -p 10 --library-type ${LIBRARY_TYPE} --output-dir ${LAB} ${GTF} ${BAM}

# sbatch ~/scripts/cufflinks_cluster.sh /data/projects/SYBACOL/mRNA_profiling_of_longevity_pathway_mutants_in_Celegans/Yidong_Germline_daf16/bam/N2_sorted.bam /data/projects/SYBACOL/annotation/Caenorhabditis_elegans.WBcel215.70_gffread_cuffcmp.combined.gtf /data/Genomes/C_elegans/Caenorhabditis_elegans.WBcel215.70_MaskFile.gtf N2
