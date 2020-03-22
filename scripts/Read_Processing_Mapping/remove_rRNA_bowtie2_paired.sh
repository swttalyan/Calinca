#!/bin/bash
#export READ1=$1
#export READ2=$2
#export INDEX=$3
module load bowtie2
#bowtie2 -x /home/sweta/Desktop/LncRNAIdentificationSoftware/Scripts/GitCode/data/bowtie2rRNAindex/contaminants -S /dev/null --un-conc-gz rrna_free_reads/SRR1703431no_rRNA --al-conc-gz rrna_free_reads/SRR1703431_rRNA  -1 trimmed_reads/SN7640204_13427_cS_221223_dep_flexbar_1.fastq.gz -2 trimmed_reads/SN7640204_13427_cS_221223_dep_flexbar_2.fastq.gz

bowtie2 -x $3 -1 $1 -2 $2 -S /dev/null --un-conc-gz $4"no_rRNA" --al-conc-gz $4"_rRNA" >& $5
