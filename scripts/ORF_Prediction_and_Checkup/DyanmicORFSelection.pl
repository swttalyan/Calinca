#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq);

#use Statistics::R ;


my $num_args=$#ARGV+1;
if($num_args !=2)
{
print "Usage of Program: perl DyanmicORFLengthSelection_Transdecoder_NewVersion.pl InputFile:transcripts.fasta.transdecoder.bed OutputFileName\n";
exit;
### perl DyanmicORFLengthSelection_Transdecoder_NewVersion.pl /prj/Most_Lab_pig_spatial_transcriptome/proteomicsDB/transcripts.fasta.transdecoder.bed TestingORF.txt
}


######### Equation from ME Dinger et all Plos computational Biology, 2008
################### equation y=91.ln(x)-330


##/prj/Most_Lab_pig_spatial_transcriptome/proteomicsDB/transcripts.fasta.transdecoder.bed
## TCONS_00000001	0	937	ID=TCONS_00000001.p1;GENE.TCONS_00000001~~TCONS_00000001.p1;ORF_type:complete_len:275_(+),score=40.54,ENSP00000262193.6|95.021|8.32e-172	0	+	101	82701	937	0

my $inputFile=$ARGV[0];
my $outputFile=$ARGV[1];

my $uniqrecords =`sort -k1,1 -k4,4 $inputFile | sort -u -k1,1| grep -v -P "track name"`;
my @bedrecords=split("\n",$uniqrecords);

open (F1,">".$outputFile)  || die "Could not create the file";
print F1 "TCONSid\tORF_Id\ttTCONSlen[bp]\tActualyORFlenfromInputFile[bp]\tORFlenbyME_Dinger_Equation[bp]\tORFStatus\n";


foreach my $line (@bedrecords)
{
	chomp $line;
	if($line=~m/(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)/)
	{
	my $TCONS= $1; my $TCONSlen=$3; my $recordName=$4;
	### ID=TCONS_00000001.p1;GENE.TCONS_00000001~~TCONS_00000001.p1;ORF_type:complete_len:275_(+),score=40.54,ENSP00000262193.6|95.021|8.32e-172

	##### transcript id
	#print F1 $TCONS."\t";
	

	######## ORF ID
	my @ORF_ID=split ("\\;",$recordName);
	$ORF_ID[0]=~tr/ID=//;
	#print F1 $ORF_ID[0]."\t";
		
	#### TCONS length
	#print F1 $TCONSlen."\t";


	######## TCONS ORF length
	my @ORF_len=split("\\_len:",$recordName);
	my @ORF_other=split("\\_\\(",$ORF_len[1]);
	my $orf_length=$ORF_other[0]*3;
	#print F1 $orf_length."\t";


		my $eqORFlen=180+91*log($TCONSlen)-330;
		print F1 $eqORFlen."\t";
		if($orf_length<=$eqORFlen)
		{
		print F1 $TCONS."\t".$ORF_ID[0]."\t". $TCONSlen."\t". $orf_length."\t","BelowCurve:noORF\n";	
		}
	}
}


close F1;

