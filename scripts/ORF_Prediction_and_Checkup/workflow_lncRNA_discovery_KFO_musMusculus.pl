#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

my $args=$#ARGV+1;
if($args!=7)
{
print "\tUsage of the script: perl workflow_lncRNA_discovery_KFO_musMusculus.pl transcriptGTFFile transcriptFastaFile ProteinsDB TransDecoderInstallationPath refGTFfile refGenomeFasta refRepeatMasker File\n\n";
exit;
}

## command to run the script for Step1
# perl scripts/ORF_Prediction_and_Checkup/workflow_lncRNA_discovery_KFO_musMusculus.pl transcripts.gtf transcripts.fasta data/SwissProt/uniprot_sprot.fasta /biosw/transdecoder/5.5.0 /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa data/GRCm38_90_repeatmasker.bed

my $transcriptGTF=shift @ARGV;
my $transcriptfile = shift @ARGV;
my $proteinDB=shift @ARGV;
my $TDPATH=shift @ARGV;
my $refGTF=shift @ARGV;
my $refGenome=shift @ARGV;
my $refRepeatMasker=shift @ARGV;
#my @files;

system("mkdir -p Output/ORFPredictionAndCheckup/");
system ("cp $transcriptfile Output/ORFPredictionAndCheckup/");
system ("cp $transcriptGTF Output/ORFPredictionAndCheckup/");
system ("cp $refRepeatMasker Output/ORFPredictionAndCheckup/repeats.bed");
chdir("Output/ORFPredictionAndCheckup/") || die "Could not change to wdir";
system("mkdir -p transdecoder");
system("mv $transcriptfile transdecoder/transcripts.fasta");
system ("mv $transcriptGTF transdecoder/transcripts.gtf");
system ("mv repeats.bed transdecoder/repeats.bed");
#Commands to run Transdecoder on input transcripts fasta file
print "\n\nStep3a: Run TranscDecoder on input transcripts fasta file\n\n";

#### create file for running transdecoder commands
open(TD,">transdecoder/transdecoderScript.sh") || die "Could not generate bash script";
print TD "#!/bin/bash\n";
print TD "cd transdecoder\n";
########## predicted ORF
print TD $TDPATH."/TransDecoder.LongOrfs -m 50 -t transcripts.fasta\n";
######## run blast command based on longORF
print TD "makeblastdb -in $proteinDB -dbtype prot\n";
print TD "#blastp -query transcripts.fasta.transdecoder_dir/longest_orfs.pep -db $proteinDB -max_target_seqs 1 -outfmt 6 -evalue 1e-5 -num_threads 10 >blastoutput.outfmt6\n";
print TD $TDPATH."/TransDecoder.Predict -t transcripts.fasta --retain_blastp_hits blastoutput.outfmt6\n";
print TD "cut -f1 transcripts.fasta.transdecoder.bed |sort -u > orf_transdecoder_ids.txt\n";
print TD "sort -k4,4 -V transcripts.fasta.transdecoder.bed | sort -k1,1 -u >transdecoder.singlebesthit.bed\n";
close(TD);

system ("chmod u+x transdecoder/transdecoderScript.sh");
system ("/bin/bash transdecoder/transdecoderScript.sh") == 0 or die "Bash Script failed";
my $no50aaORF=`perl ../../scripts/ORF_Prediction_and_Checkup/disselect_from_GTF.pl transdecoder/orf_transdecoder_ids.txt transdecoder/transcripts.gtf`;
open (NO,">transdecoder/no50aaORF.gtf") || die "Could not create file";
print NO $no50aaORF."\n";
close (NO);

system ("perl ../../scripts/ORF_Prediction_and_Checkup/DyanmicORFSelection.pl transdecoder/transcripts.fasta.transdecoder.bed transdecoder/BelowCurve.txt");
#my $BelowCurve=`perl ../../scripts/ORF_Prediction_and_Checkup/disselect_from_GTF.pl transdecoder/BelowCurve.txt transdecoder/transcripts.gtf`;
#open (BC,">transdecoder/BelowCurve.gtf") || die "Could not create file";
#print BC $BelowCurve."\n";
#close (BC);


print "\n\nStep3b: Selection of final candidates based on ORF cutoff\n\n";
system ("mkdir -p FinalLncRNACandidates");

system ("cp ../../scripts/ORF_Prediction_and_Checkup/SelectionOfCandidates.sh FinalLncRNACandidates");
system ( "/bin/bash FinalLncRNACandidates/SelectionOfCandidates.sh $refGTF $refGenome"); 


print "\n\nStep3: ORF prediction and check up is finished\n\n";
