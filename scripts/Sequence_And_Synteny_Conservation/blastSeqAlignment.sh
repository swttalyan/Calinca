#!/bin/bash

#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=500G

module load blast
module load gffread

export queryFasta=$1
export databaseGTF=$2
export databaseFasta=$3

cd Output/SequenceAndSyntencyConservation
gffread ${databaseGTF} -g ${databaseFasta} -w SequenceConservation/databasefastafilehuman.fasta

cd SequenceConservation
makeblastdb -in databasefastafilehuman.fasta -dbtype nucl 

blastn -query ${queryFasta} -db databasefastafilehuman.fasta -outfmt 6 -out blastlncRNARxAgainstHumanTx.outfmt 

awk '{if(($4>=100)&&($3>=80)) print $line}' blastlncRNARxAgainstHumanTx.outfmt | sort -k12,12 -g -r | sort -k1,1 -u >lncRNAConservedAtSequences.txt

echo "Step4a: Sequences conservation step is finished\n\n"
