#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=100G

export BAM=$1
export OUTPUT=$2
export LIBRARY_TYPE=$3

module load scallop

mkdir -p ${OUTPUT}

if [ ! $LIBRARY_TYPE ]
then
    echo "Case1"
    scallop -i ${BAM} -o ${OUTPUT}"/scallop_outfile.gtf" --min_splice_bundary_hits 2 --library_type first
elif [ $LIBRARY_TYPE == 'fr-secondstrand' ]
then
    echo "Case2"
    scallop -i ${BAM} -o ${OUTPUT}"/scallop_outfile.gtf" --min_splice_bundary_hits 2 --library_type second
elif [ $LIBRARY_TYPE == 'fr-firststrand' ]
then
    echo "Case 3"
    scallop -i ${BAM} -o ${OUTPUT}"/scallop_outfile.gtf" --min_splice_bundary_hits 2 --library_type first
elif [ $LIBRARY_TYPE == 'fr-unstranded' ]
then
    echo "Case 4"
    scallop -i ${BAM} -o ${OUTPUT}"/scallop_outfile.gtf" --min_splice_bundary_hits 2 --library_type unstranded
fi

#stringtie ${BAM} -p 10 -G ${GTF} --rf -o ${OUTPUT}"/stringtie_outfile.gtf" -j 2 -C ${OUTPUT}"/fully_covered.gtf"

# sbatch ~/scripts/cufflinks_cluster.sh /data/projects/SYBACOL/mRNA_profiling_of_longevity_pathway_mutants_in_Celegans/Yidong_Germline_daf16/bam/N2_sorted.bam /data/projects/SYBACOL/annotation/Caenorhabditis_elegans.WBcel215.70_gffread_cuffcmp.combined.gtf /data/Genomes/C_elegans/Caenorhabditis_elegans.WBcel215.70_MaskFile.gtf N2
