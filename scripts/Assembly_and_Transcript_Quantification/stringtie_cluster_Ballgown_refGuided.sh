#!/bin/bash
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem=100G

export BAM=$1
export GTF=$2
export OUTPUT=$3
export LIBRARY_TYPE=$4

module load stringtie/1.3.3b

mkdir -p ${OUTPUT}

if [ ! $LIBRARY_TYPE ]
then
    stringtie ${BAM} -v -p 10 -G ${GTF} --rf -o ${OUTPUT}"/stringtieB_outfile.gtf" > /dev/null 2>&1
elif [ $LIBRARY_TYPE == 'fr-secondstrand' ]
then
    stringtie ${BAM} -v -p 10 -G ${GTF} --fr -o ${OUTPUT}"/stringtieB_outfile.gtf" > /dev/null 2>&1
elif [ $LIBRARY_TYPE == 'fr-firststrand' ]
then
    stringtie ${BAM} -v -p 10 -G ${GTF} --rf -o ${OUTPUT}"/stringtieB_outfile.gtf" > /dev/null 2>&1
elif [ $LIBRARY_TYPE == 'fr-unstranded' ]
then
    stringtie ${BAM} -v -p 10 -G ${GTF} -o ${OUTPUT}"/stringtieB_outfile.gtf" > /dev/null 2>&1
fi



# sbatch ~/scripts/cufflinks_cluster.sh /data/projects/SYBACOL/mRNA_profiling_of_longevity_pathway_mutants_in_Celegans/Yidong_Germline_daf16/bam/N2_sorted.bam /data/projects/SYBACOL/annotation/Caenorhabditis_elegans.WBcel215.70_gffread_cuffcmp.combined.gtf /data/Genomes/C_elegans/Caenorhabditis_elegans.WBcel215.70_MaskFile.gtf N2
