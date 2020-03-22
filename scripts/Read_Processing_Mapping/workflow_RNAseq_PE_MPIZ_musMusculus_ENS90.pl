#!/usr/bin/perl
use strict;
use warnings;


my $num=$#ARGV+1;
if($num !=6)
{
print "Usage of the Script: perl workflow_RNAseq_PE_MPIZ_musMusculus_ENS90.pl FilewithSamplesName FastQ1Extension FastQ2Extension rRNAcontaminationFile PathToRefGTF PathToStarIndexFile \n";
exit;
}

# Command to run step 1:
###  perl scripts/Read_Processing_Mapping/workflow_RNAseq_PE_MPIZ_musMusculus_ENS90.pl samplefile.txt _1.fastq.gz _2.fastq.gz /prj/KFO329/index/contaminants  /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/star/



my $readNames = shift @ARGV;
my @files;


my $readSuffix =shift @ARGV;
my $readSuffix2 =shift @ARGV;

open(IN,$readNames) || die "Could not open readNames";
while(my $r = <IN>)
{
#print $r."\n";
    chomp $r;
    push(@files,$r);
}
close(IN);

#chdir($wdir) || die "Could not change to wdir";
system("mkdir -p Output");
system("mkdir -p Output/ReadProcessingAndMapping");
system("mkdir -p Output/ReadProcessingAndMapping/raw_reads");
system("mkdir -p Output/ReadProcessingAndMapping/trimmed_reads");
system("mkdir -p Output/ReadProcessingAndMapping/rrna_free_reads");
system("mkdir -p Output/ReadProcessingAndMapping/mapping");


# Input parameters
my $rRNA_mtRNA = shift @ARGV;
my $gtf = shift @ARGV;
my $index = shift @ARGV;

print "\nStep 1a PROCESSING: prepareing raw fastq files for processing ...\n";
my @file2; my @filename;
foreach my $f (@files)
{
	@filename=split("\/",$f);
	system("ln -sfn ".$f." Output/ReadProcessingAndMapping/raw_reads");
	push(@file2,"Output/ReadProcessingAndMapping/raw_reads/".$filename[-1]);
}

print "\nDONE\n";

@file2 = grep (/$readSuffix/, @file2);
@file2 = map {s/$readSuffix//g; $_;} @file2;

my @flexfiles = @file2;
@flexfiles = map { s/raw_reads/trimmed_reads/g;$_} @flexfiles;
@flexfiles=map {$_."_flexbar_1.fastq.gz"} @flexfiles;

print "\nStep 1b TRIMMING: flexbar command to remove adapter sequence ...\n";
for(my $t=0;$t<@file2;$t++)
{
	my $out = $file2[$t];
 	$out =~ s/raw_reads/trimmed_reads/g;
	#system("\t scripts/Read_Processing_Mapping/flexbar_paired_30.sh $file2[$t]"."$readSuffix $file2[$t]"."$readSuffix2 $out"."_flexbar\n\n");
}
print "\nDONE\n";

print "\nStep 1c RRNA : Bowtie2 command to remove rRNA and mitochondrial sequence ...\n";

my @rrnafiles = @file2;
@rrnafiles = map {s/raw_reads/rrna_free_reads/g;$_ } @rrnafiles;
@rrnafiles=map {$_."_rRNAfree_1.fastq.gz"} @rrnafiles;


for(my $t=0;$t<@file2;$t++)
  {
	my $out = $file2[$t];
	$out=~s/raw_reads/rrna_free_reads/g;
    	my $tmp = $flexfiles[$t];
    	$tmp=~s/flexbar_1.fastq.gz/flexbar_2.fastq.gz/g;
	system("\t scripts/Read_Processing_Mapping/remove_rRNA_bowtie2_paired.sh ".$flexfiles[$t]." ".$tmp." ".$rRNA_mtRNA." ".$out." ".$out.".log\n");
    	system ("\tmv ".$out."no_rRNA.1 ".$out."_rRNAfree_1.fastq.gz\n");
    	system ("\tmv ".$out."no_rRNA.2 ".$out."_rRNAfree_2.fastq.gz\n\n");
}


print "\nDONE\n";
print "\nStep 1d MAPPING : star command to map the reads to reference genome ...\n";

for(my $t=0;$t<@file2;$t++)
{
    	$rrnafiles[$t]=~s/trimmed_reads/rrna_free_reads/g;
	my $tmp = $rrnafiles[$t];
   	$tmp=~s/_1.fastq.gz/_2.fastq.gz/g;
	my $out=$file2[$t];
	$out=~s/raw_reads/mapping/g;
	#$out=$out."_";
	system ("\t \./scripts/Read_Processing_Mapping/STARalliance_circles_DCC_singlePass.sh ".$out." ".$rrnafiles[$t]." ".$tmp." ".$index." ".$gtf."\n"); 
}

print "\nDONE\n";

print "\nSTEP1: Processing and Mapping of Reads to reference genome finished\n\n";
