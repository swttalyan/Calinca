#!/usr/bin/perl
use strict;
use warnings;


my $args=$#ARGV+1;
if($args!=6)
{
print "\tUsage of the script: perl Sequence_And_Synteny_Conservation_Workflow.pl LncRNACandidatesGTFFile LncRNACandidatesFastaFile MouseGTFfile MouseGenomeSeqFile HumanGTFfile HumanGenomeSeqFile\n\n";
exit;
}

## command to run the script for Step4
#perl scripts/Sequence_And_Synteny_Conservation/Sequence_And_Synteny_Conservation_Workflow.pl /prj/KFO329/WP1-Podocyte_enriched_lncRNAs/CalincaDataSetAnalysis01_2020/lncRNAPipelineAnalysis/Calinca/Scripts/GitCode/Output/ORFPredictionAndCheckup/FinalLncRNACandidates/merged_asm/merged.gtf /prj/KFO329/WP1-Podocyte_enriched_lncRNAs/CalincaDataSetAnalysis01_2020/lncRNAPipelineAnalysis/Calinca/Scripts/GitCode/Output/ORFPredictionAndCheckup/FinalLncRNACandidates/merged_asm/merged.fasta /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa /biodb/genomes/homo_sapiens/GRCh38_90/GRCh38.90.gtf /biodb/genomes/homo_sapiens/GRCh38_90/GRCh38_90.fa


my $lncRNAGTF=shift @ARGV;
my $lncRNAFASTA = shift @ARGV;
my $mouseRefGTF=shift @ARGV;
my $mouseRefSEQ=shift @ARGV;
my $humanRefGTF=shift @ARGV;
my $humanRefSEQ=shift @ARGV;

system("mkdir -p Output/SequenceAndSyntencyConservation");
system ("mkdir -p Output/SequenceAndSyntencyConservation/SequenceConservation");
system ("mkdir -p Output/SequenceAndSyntencyConservation/SyntenyConservation");


########### First step is running the blast scripts and creating the fasta files
### Note: this blast script is running by selecting all type of human transcripts against lncRNA transcripts candidates and only reporting those which have percent identity more then 80% and alignment length more then 100 base pairs. This is blastn alignment.
 
system ("/bin/bash scripts/Sequence_And_Synteny_Conservation/blastSeqAlignment.sh $lncRNAFASTA $humanRefGTF $humanRefSEQ");

#### this cyntenator results are based on the gene order conservation between protein coding genes of human and mouse and then check the overlap of mouse protein coding genes with lncRNA transcripts and also within 10KB upsteam and downstream.

system ("/bin/bash scripts/Sequence_And_Synteny_Conservation/cyntenatorScript.sh  $lncRNAGTF $mouseRefGTF $mouseRefSEQ $humanRefGTF $humanRefSEQ");

