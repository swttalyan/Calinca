#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=50G

module load blast

#/biosw/transdecoder/2.0.1/util/cufflinks_gtf_genome_to_cdna_fasta.pl RatLncRNA.gtf /biodb/genomes/rattus_norvegicus/Rnor_6_0_90/Rnor_6_0_90.fa > RatLncRNA.fasta

makeblastdb -in GRCh38.90.genes.fasta -dbtype nucl

blastn -query GRCm38.90.genes.fasta -db GRCh38.90.genes.fasta -outfmt 6 -out mouse_human_genes_alignments.txt 

makeblastdb -in GRCm38.90.genes.fasta -dbtype nucl

blastn -query GRCh38.90.genes.fasta -db GRCm38.90.genes.fasta -outfmt 6 -out human_mouse_genes_alignments.txt
