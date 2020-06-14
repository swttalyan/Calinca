#!/bin/perl
use warnings;
use strict;

#input prefix File
use File::Basename;

my $args=$#ARGV+1;
if($args!=5)
{
print "\tUsage of the script: perl submit_StringTieQuant_homoSapiens_ENS90.pl ListofBAMFilesForTxAssembly ReferencegenomeGTFFile ReferencegenomeFastaFile librarytype ListofBAMFilesForQuantification\n";
exit;
}

## command to run the script for Step1
# perl scripts/Assembly_and_Transcript_Quantification/submit_StringTieQuant_homoSapiens_ENS90.pl BAMFilesForTxAssembly.txt /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa fr-firststrand BAMFilesForTxQuantifications.txt

##### parsing command line parameters
my $inputFiles = shift @ARGV;
my $gtfFile = shift @ARGV;

my $refGenome = shift @ARGV;
my $library_type=shift @ARGV;
my $bamQuant=shift @ARGV;


#chdir($wdir) || die "Could not change to wdir";
system("mkdir -p Output");
system("mkdir -p Output/TranscriptAssemblyAndabundanceEstimation");
system("mkdir -p Output/TranscriptAssemblyAndabundanceEstimation/TranscriptAssembly");
system("mkdir -p Output/TranscriptAssemblyAndabundanceEstimation/TranscriptAbundance");
system("mkdir -p Output/TranscriptAssemblyAndabundanceEstimation/SelectedCandidates");
#my $cuffcmp_gtfFile = "/biodb/genomes/mus_musculus/GRCm38_90/cuffcmp.GRCm38.90.gtf";

my $mergedGTF = "Output/TranscriptAssemblyAndabundanceEstimation/merged_asm/merged.gtf";
print "\nStep2a: Denovo transcripts assembly using the input bam file\n\n";

open(my $fh, '<:encoding(UTF-8)', $inputFiles)
or die "Could not open file '$inputFiles' $!";
while(<$fh>)
{
    chomp;
    #change input format: ./SID6724_S1_L004_STARmapping/Aligned.noS.bam
	my $prefix = $_;
	#print "prefix\t".$prefix."\n";
	my $STAR_folder = "Output/TranscriptAssemblyAndabundanceEstimation/TranscriptAssembly/";
	#print "STAR Folder\t".$STAR_folder."\n";
	my $bam_file = $_;
	my @Sample = split ("\/", $bam_file);
	my $sampleName=$STAR_folder.$Sample[-2];
	my $bam_pref = $STAR_folder."/Aligned.noS";
	#print "BAM file prefix\t".$bam_pref."\n";

	if(-e $bam_file)
      	{
	# Submit StringTie for denovo tx assembly
	## Run me
	system ("\tscripts/Assembly_and_Transcript_Quantification/stringtie_cluster_Ballgown_refGuided.sh ".$bam_file." ".$gtfFile." ".$sampleName."_RefGuidedStringTieAssembly"." ".$library_type."\n");
	#print "\tscripts/Assembly_and_Transcript_Quantification/stringtie_cluster_Ballgown_refGuided.sh ".$bam_file." ".$gtfFile." ".$sampleName."_RefGuidedStringTieAssembly"." ".$library_type."\n";
	}

}
## Run me
### Merging of transcript assembly
print "\tStep2b: Merging of denovo and reference transcript assembly\n\n";

system ("\tscripts/Assembly_and_Transcript_Quantification/cuffmerge_StringTieAssembly.sh ".$gtfFile." ".$refGenome."\n");
print "\tscripts/Assembly_and_Transcript_Quantification/cuffmerge_StringTieAssembly.sh ".$gtfFile." ".$refGenome."\n";

############# calculation of abundance of merged transcripts in input BAM files
print "\nStep2c: Transcripts abundance calculation based on input BAM files\n\n";


open(my $fhh, '<:encoding(UTF-8)', $bamQuant)
or die "Could not open file '$bamQuant' $!";

while(<$fhh>)
{
    chomp;
        my $prefix = $_;
        #print "prefix\t".$prefix."\n";
        my $STAR_folder = "Output/TranscriptAssemblyAndabundanceEstimation/TranscriptAbundance/";
        #print "STAR Folder\t".$STAR_folder."\n";
        my $bam_file = $_;
        my @Sample = split ("\/", $bam_file);
        my $sampleName=$STAR_folder.$Sample[-2];
        my $bam_pref = $STAR_folder."/Aligned.noS";
        #print "BAM file prefix\t".$bam_pref."\n";

        if(-e $bam_file)
        {
        # Submit StringTie for denovo tx assembly
        ## Run me
        system ("\tscripts/Assembly_and_Transcript_Quantification/stringtie_cluster_Ballgown.sh ".$bam_file." ".$mergedGTF." ".$sampleName."_StringTieQuantification"."\n");
        #print "\tscripts/Assembly_and_Transcript_Quantification/stringtie_cluster_Ballgown.sh ".$bam_file." ".$mergedGTF." ".$sampleName."_StringTieQuantification"."\n";
        }
}


#### Select number of candidates transcripts based on FPKM and length
print "\n\nStep2d: Select transcripts based on expression and length\n\n";

my $quantFiles=`find Output/TranscriptAssemblyAndabundanceEstimation/TranscriptAbundance/ -iname stringtieB_outfile.gtf`;


my @qFiles=split("\n",$quantFiles);
system("> TCONSselected.txt");
foreach my $line (@qFiles)
{
chomp $line;
## Run me
`grep -w "transcript" $line | awk '{print \$12"\t"\$(NF-2)}' | sed 's/"//g' | sed 's/;//g'| awk '{if(\$2>=1) print \$1}' >>TCONSselected.txt`;

} 
system ("\tscripts/Assembly_and_Transcript_Quantification/selectedTCONS.sh ".$mergedGTF." ".$refGenome."\n");


print "\nStep2: Transcript assembly and abundance calculation is completed\n\n";
