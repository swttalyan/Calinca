#!/bin/bash

#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=50G

export lncRNAGTF=$1
export MouseGTF=$2
export MouseSEQ=$3
export HumanGTF=$4
export HumanSEQ=$5



module load blast
module load gffread
module load bedtools/2.23.0

cd Output/SequenceAndSyntencyConservation/SyntenyConservation/

#### Select protein coding annotations from human and mouse
echo "Step4b: processing the files for blast"

grep -w "protein_coding" ${MouseGTF} >mouse_pc.gtf
grep -w "protein_coding" ${HumanGTF} >human_pc.gtf

gffread mouse_pc.gtf -g ${MouseSEQ} -w mouse_pc.fasta
gffread human_pc.gtf -g ${HumanSEQ} -w human_pc.fasta 

grep -w "transcript" ${MouseGTF} | awk '{print $14"\t"$10}' | sed 's/;//g' |sed 's/"//g' >mouse_pcNames.txt
grep -w "transcript" ${HumanGTF} | awk '{print $14"\t"$10}' | sed 's/;//g' |sed 's/"//g' >human_pcNames.txt

awk 'FNR==NR{a[">"$1]=$2;next}$1 in a{sub(/>/,">"a[$1]"|",$1)}1' mouse_pcNames.txt mouse_pc.fasta >mouse_pc_new.fasta
awk 'FNR==NR{a[">"$1]=$2;next}$1 in a{sub(/>/,">"a[$1]"|",$1)}1' human_pcNames.txt human_pc.fasta >human_pc_new.fasta

echo "Step4b: running blast on the input processed files"

rm mouse_pcNames.txt human_pcNames.txt

makeblastdb -in mouse_pc_new.fasta -dbtype nucl
makeblastdb -in human_pc_new.fasta -dbtype nucl

blastn -query mouse_pc_new.fasta -db human_pc_new.fasta -max_target_seqs 5 -outfmt 6 -evalue 1e-5 -num_threads 10 >blastoutputMouseToHuman.outfmt6 
blastn -query human_pc_new.fasta -db mouse_pc_new.fasta -max_target_seqs 5 -outfmt 6 -evalue 1e-5 -num_threads 10 >blastoutputHumanToMouse.outfmt6 

awk '{print $1"\t"$2"\t"$12}' blastoutputMouseToHuman.outfmt6 | sed 's/|/\t/g' | awk '{print $1" "$3" "$5}' >human_mouse_allgenes_5hits.blast
awk '{print $1"\t"$2"\t"$12}' blastoutputHumanToMouse.outfmt6 | sed 's/|/\t/g' | awk '{print $1" "$3" "$5}' >>human_mouse_allgenes_5hits.blast


######## merge both way blast alignments

#### create cyntenator file

echo "Step4b: processing files for cyntenator"
echo "#genome" >mouse_pc_inputfile.txt

#ENSG00000186092 1 65419 71585 +

echo "#genome" >human_pc_inputfile.txt


grep -w "gene" ${MouseGTF} | grep -w "protein_coding" | awk '{print $10" "$1" "$4" "$5" "$7}' | sed 's/;//g' | sed 's/"//g' >>mouse_pc_inputfile.txt
grep -w "gene" ${HumanGTF} | grep -w "protein_coding" | awk '{print $10" "$1" "$4" "$5" "$7}' | sed 's/;//g' | sed 's/"//g'  >>human_pc_inputfile.txt

echo "Step4b: running cyntenator on the input files"
./../../../scripts/Sequence_And_Synteny_Conservation/cyntenator/cyntenator -last -t "(human_pc_inputfile.txt mouse_pc_inputfile.txt)" -h blast human_mouse_allgenes_5hits.blast "(mouse_pc_inputfile.txt mouse_pc_inputfile.txt)" >pc_mouse_human_cyntenator_output.txt

awk '{print $4}' pc_mouse_human_cyntenator_output.txt | sed 's/-//g' | sed '/^$/d' | sort -u >mouse_pc_genesOrderConserved.txt

grep -Fwf mouse_pc_genesOrderConserved.txt mouse_pc_inputfile.txt | awk '{print "chr"$2"\t"$3"\t"$4"\t"$1"\t0\t"$5}' >mouse_pc_genesOrderConserved.bed

awk '{print "chr"$1"\t"$4"\t"$5"\t"$12"\t0\t"$7}' ${lncRNAGTF} | sed 's/"//g' | sed 's/;//g' >lncRNACandidates.bed

awk '{print $1"\t"$2-10000"\t"$3+10000"\t"$4"\t"$5"\t"$6}' lncRNACandidates.bed >lncRNACandidates10kUpAndDown.bed

bedtools intersect -a lncRNACandidates.bed -b mouse_pc_genesOrderConserved.bed -wo >lncRNACandidates_overlapwithMousepcGenesConservedwithHumanpcGenes.txt

bedtools intersect -a lncRNACandidates10kUpAndDown.bed -b mouse_pc_genesOrderConserved.bed -wo >lncRNACandidates10kUpAndDown_overlapwithMousepcGenesConservedwithHumanpcGenes.txt


