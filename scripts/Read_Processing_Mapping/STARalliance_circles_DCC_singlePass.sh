#!/bin/bash

export PREFIX=$1
export READFIX=$2
export READFIXX=$3
export INDEX=$4
export GTF=$5
#--chimOutType
module load samtools
module load star
rm -f -r ${PREFIX}"_STARmapping"
mkdir ${PREFIX}"_STARmapping"

STAR --runThreadN 10 --quantMode GeneCounts --genomeDir ${INDEX} --genomeLoad NoSharedMemory --readFilesIn ${READFIX}  ${READFIXX} --readFilesCommand zcat --outFileNamePrefix ${PREFIX}"_STARmapping/" --outReadsUnmapped Fastx  --outSJfilterOverhangMin 15 15 15 15 --alignSJoverhangMin 15 --alignSJDBoverhangMin 10 --outFilterMultimapNmax 20 --outFilterScoreMin 1   --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.05 --outFilterMatchNminOverLread 0.7 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000  --chimSegmentMin 15  --chimScoreMin 15   --chimScoreSeparation 10  --chimJunctionOverhangMin 15 --sjdbGTFfile ${GTF} --twopassMode Basic --chimOutType SeparateSAMold --alignSoftClipAtReferenceEnds No --outSAMattributes NH HI AS nM NM MD jM jI XS

cd  ${PREFIX}"_STARmapping"

awk 'BEGIN {OFS="\t"} {split($6,C,/[0-9]*/); split($6,L,/[SMDIN]/); if (C[2]=="S") {$10=substr($10,L[1]+1); $11=substr($11,L[1]+1)}; if (C[length(C)]=="S") {L1=length($10)-L[length(L)-1]; $10=substr($10,1,L1); $11=substr($11,1,L1); }; gsub(/[0-9]*S/,"",$6); print}' Aligned.out.sam > Aligned.noS.sam

#awk 'BEGIN {OFS="\t"} {split($6,C,/[0-9]*/); split($6,L,/[SMDIN]/); if (C[2]=="S") {$10=substr($10,L[1]+1); $11=substr($11,L[1]+1)}; if (C[length(C)]=="S") {L1=length($10)-L[length(L)-1]; $10=substr($10,1,L1); $11=substr($11,1,L1); }; gsub(/[0-9]*S/,"",$6); print}' Chimeric.out.sam > Chimeric.noS.sam

grep "^@" Aligned.out.sam > header.txt

rm -f Aligned.out.sam
rm -f Chimeric.out.sam

rm -f -r _STARgenome
rm -f -r _STARpass1

samtools view -bS Aligned.noS.sam | samtools sort -@ 10 -m 2G -T tempo -o Aligned.noS.bam /dev/stdin 
samtools reheader header.txt Aligned.noS.bam > Aligned.noS.tmp
mv Aligned.noS.tmp Aligned.noS.bam
samtools index Aligned.noS.bam


rm -f Aligned.noS.sam


gzip -c Unmapped.out.mate1 > Unmapped_mate1.fastq.gz
rm -f Unmapped.out.mate1
if [ -f Unmapped.out.mate2 ]
then
    gzip -c Unmapped.out.mate2 > Unmapped_mate2.fastq.gz
    rm -f Unmapped.out.mate2
fi

cd ..

#
#sbatch -J podocyte_1 ~/scripts/STARalliance_circles_wig.sh podocyte_1 /data/sra/external/Roman_Mueller/SRP051053/SRR1703430.fastq.gz /data/__DELETION_PENDING__/old_Indices/STAR/M_musculus/ENSEMBL.mus_musculus.release-75

#--runThreadN 10   --genomeDir [genome]  --outSAMtype BAM Unsorted --readFilesIn Sample1_1.fastq.gz  Sample1_2.fastq.gz   --readFilesCommand zcat  --outFileNamePrefix [sample prefix] 
#/data/genomes/mus_musculus/GRCm38_79/STAR/2.4.1c
#--sjdbGTFfile /data/genomes/mus_musculus/GRCm38_79/GRCm38.79.gtf
#sbatch -J testdrive -p blade ~/scripts/STARalliance_circles_DCC.sh  wt20038 /data/projects/departments/Linda_Partridge/Paul_Essers/raw_trimmed/merged/wt20038.fastq.gz /data/genomes/mus_musculus/GRCm38_79/STAR/2.4.1c /data/genomes/mus_musculus/GRCm38_79/GRCm38.79.gtf
