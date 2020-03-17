#!/bin/perl
#input prefix File
use File::Basename;

my $args=$#ARGV+1;
if($args!=1)
{
print "\tUsage of the script: perl submit_StringTieQuant_homoSapiens_ENS90.pl ListFilewithLocationofBAMfileinStarResults \n";
exit;
}

my $index = "/biodb/genomes/mus_musculus/GRCm38_90/star";
my $gtfFile = "/biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf ";
my $cuffcmp_gtfFile = "/biodb/genomes/mus_musculus/GRCm38_90/cuffcmp.GRCm38.90.gtf";

my $mergedGTF = "merged_asm/merged.gtf";
my $refGenome = "/biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa";

my $library_type = "fr-firststrand";

my @job_dependencies;
my @bamfiles;

while(<>)
  {
    chomp;
    #change input format: ./SID6724_S1_L004_STARmapping/Aligned.noS.bam
my $prefix = $_;
my $STAR_folder = dirname($prefix);
my $bam_file = $STAR_folder."/Aligned.noS.bam";
my $bam_pref = $STAR_folder."/Aligned.noS";
   
    if(-e $bam_file)
      {

#correct BAM file too
#$command = "sbatch --time=03:00:00 -p blade,himem -J correct_".$prefix." /home/cdieterich/scripts/correctBAM.sh ".$bam_pref;
#my $ret = `$command 2>&1`;
#chomp $ret;

#$ret=~/(\d+)/;
#my $jid = $1;

#submit Ballgown
$command = "sbatch --time=03:00:00 -J StringTie_".basename($prefix)." /home/cdieterich/scripts/stringtie_cluster_Ballgown.sh ".$bam_file." ".$gtfFile." ".$STAR_folder."_StringTieBallgown"." ".$library_type;
print $command,"\n";
$ret = `$command 2>&1`;
chomp $ret;

$command = "sbatch --time=03:00:00  -J StringTie2_".basename($prefix)." /home/cdieterich/scripts/scallop.sh ".$bam_file." ".$STAR_folder."_Scallop ".$library_type;
print $command,"\n";
$ret = `$command 2>&1`;
chomp $ret;

$ret=~/(\d+)/;

push(@job_dependencies,$1);
print $1,"\n";
push(@bamfiles,$bam_file);
      }
  }
my $JobDepString = join(":",@job_dependencies);
$command = "sbatch --time=03:00:00  --dependency=afterok:".$JobDepString." -J cuffmerge /home/cdieterich/scripts/cuffmerge_scallop_cluster.sh ".$gtfFile." ".$refGenome;
print $command,"\n";
my $ret = `$command 2>&1`;
chomp $ret;

$ret=~/(\d+)/;
$JobDepString = $1;
print "Submit ".$JobDepString."\n";

#start cuffquant & cuffdiff
@job_dependencies=();


foreach my $bam (@bamfiles)
  {

    my $outputFolder = $bam;
    $outputFolder =~ s/\/Aligned.noS.bam//;
    #$outputFolder = $outputFolder."_AllStringTieBallgown";
    print $bam,"\n";
    $command = "sbatch --dependency=afterok:".$JobDepString." -J StringTie_All2_".basename($bam)." /home/cdieterich/scripts/stringtie_cluster_Ballgown.sh ".$bam." merged_asm/merged.gtf ".$outputFolder."_All_StringTieBallgown";
    print $command,"\n";
    $ret = `$command 2>&1`;
    chomp $ret;
  }
#exit(0);


foreach my $bam (@bamfiles)
  {
    my $outputFolder = $bam;
    $outputFolder =~ s/\/Aligned.noS.bam//;
    $outputFolder = $outputFolder."_All";
    $command = "sbatch --time=03:00:00 --dependency=afterok:".$JobDepString." -J cuffquant".basename($outputFolder)." /home/cdieterich/scripts/cuffquant_cluster_strand.sh ".$bam." ".$mergedGTF." ".$outputFolder." ".$library_type;
    my $ret = `$command 2>&1`;
    print $command,"\n";
    print $outputFolder,"\n";
    chomp $ret;

    $ret=~/(\d+)/;
    push(@job_dependencies,$1);
    print "cuffquant".$1."\n";
  }

foreach my $bam (@bamfiles)
  {
    my $outputFolder = $bam;
    $outputFolder =~ s/\/Aligned.noS.bam//;
    $outputFolder = $outputFolder."_Ref";
    $command = "sbatch --time=03:00:00  --dependency=afterok:".$JobDepString." -J cuffquant".basename($outputFolder)." /home/cdieterich/scripts/cuffquant_cluster_strand.sh ".$bam." ".$gtfFile." ".$outputFolder." ".$library_type;
    my $ret = `$command 2>&1`;
    print $command,"\n";
    print $outputFolder,"\n";
    chomp $ret;

    $ret=~/(\d+)/;
    push(@job_dependencies,$1);
    print "cuffquantRef".$1."\n";
  }

foreach my $bam (@bamfiles)
  {
    my $outputFolder = $bam;
    $outputFolder =~ s/\/Aligned.noS.bam//;
    $outputFolder = $outputFolder."_Refcmp";
    $command = "sbatch --time=03:00:00  --dependency=afterok:".$JobDepString." -J cuffquant".basename($outputFolder)." /home/cdieterich/scripts/cuffquant_cluster_strand.sh ".$bam." ".$cuffcmp_gtfFile." ".$outputFolder." ".$library_type;
    my $ret = `$command 2>&1`;
    #print $command,"\n";
    #print $outputFolder,"\n";
    chomp $ret;

    $ret=~/(\d+)/;
    push(@job_dependencies,$1);
    print "cuffquantRefcmp".$1."\n";
  }

#do the cuffdiff now.

#my $JobDepString = join(":",@job_dependencies);
#$command = "sbatch --time=20:00:00 -p blade,himem --dependency=afterok:".$JobDepString." -J cuffmerge /home/cdieterich/scripts/cuffmerge_cluster.sh ".$gtfFile." ".$refGenome;
#my $ret = `$command 2>&1`;
#chomp $ret;
