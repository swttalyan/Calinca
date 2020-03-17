#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq);

#use Statistics::R ;


my $num_args=$#ARGV+1;
if($num_args !=2)
{
print "Usage of Program: perl DyanmicORFLengthSelection_Transdecoder_OldVersion.pl InputFile:transcripts.fasta.transdecoder.bed OutputFileName\n";
exit;
### perl DyanmicORFLengthSelection_Transdecoder_OldVersion.pl /prj/KFO329/WP1-Podocyte_enriched_lncRNAs/JuneAnalysisKnownAndNovelNew/.nobackup/NEWAnalysis/transdecoder/transcripts.fasta.transdecoder.bed TestingORF
}


######### Equation from ME Dinger et all Plos computational Biology, 2008
################### equation y=91.ln(x)-330


##/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/JuneAnalysisKnownAndNovelNew/.nobackup/NEWAnalysis/transdecoder/transcripts.fasta.transdecoder.bed
## TCONS_00000032	0	2428	ID=TCONS_00000032|m.7356;TCONS_00000032|g.7356;ORF_TCONS_00000032|g.7356_TCONS_00000032|m.7356_type:5prime_partial_len:89_(+)	0	+	2	269	0	1	2428	0

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
	### ID=TCONS_00290316|m.245995;TCONS_00290316|g.245995;ORF_TCONS_00290316|g.245995_TCONS_00290316|m.245995_type:complete_len:70_(-)

	##### transcript id
	print F1 $TCONS."\t";
	
	######## ORF ID
	my @ORF_ID=split ("\\|",$recordName);
	print F1 $ORF_ID[3]."\t";
		
	#### TCONS length
	print F1 $TCONSlen."\t";
	
	######## TCONS ORF length
	my @ORF_len=split("\_",$ORF_ID[4]);
	$ORF_len[-2]=~s/len://;
	my $orf_length=$ORF_len[-2]*3;
	print F1 $orf_length."\t";


		my $eqORFlen=91*log($TCONSlen)-330;
		print F1 $eqORFlen."\t";
		if($orf_length<=$eqORFlen)
		{
		print F1 "noORF\n";	
		}
		else
		{
		print F1 "withORF\n";
		}
	
	}

}


close F1;

system ("Rscript DyanmicORFLengthPlotting.R $outputFile");
