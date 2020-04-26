#!/usr/bin/perl
use strict;
use warnings;


my $args=$#ARGV+1;
if($args!=6)
{
print "\tUsage of the script: perl Sequence_And_Synteny_Conservation_Workflow.pl LncRNACandidatesFastaFile LncRNACandidatesGTFFile MouseGTFfile MouseGenomeSeqFile HumanGTFfile HumanGenomeSeqFile\n\n";
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

#system ("/bin/bash scripts/Sequence_And_Synteny_Conservation/blastSeqAlignment.sh $lncRNAFASTA $humanRefGTF $humanRefSEQ");

system ("/bin/bash scripts/Sequence_And_Synteny_Conservation/cyntenatorScript.sh  $lncRNAGTF $mouseRefGTF $mouseRefSEQ $humanRefGTF $humanRefSEQ");


