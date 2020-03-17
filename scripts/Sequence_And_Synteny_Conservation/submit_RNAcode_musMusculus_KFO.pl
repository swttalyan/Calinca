#!/bin/perl
#input prefix File
use File::Basename;

my $hal = "/biodb/alignments/epo/epo.hal";
my $species = "mus_musculus";

my @job_dependencies;
my @bamfiles;

while(<>)
  {
    chomp;
    my $input = $_;
    my $bas = basename($input);
    $bas =~ s/.gtf//;
   
    if(-e $input)
      {

open(TD,">".$bas.".sh");
print TD "#!/bin/bash\n";
print TD "module unload hal\n";
print TD "module load hal \n";
print TD "module unload rnacode\n";
print TD "module load rnacode \n";
print TD "perl /home/cdieterich/scripts/get_HAL_alignments_RNAcode_homo_sapiens.pl ".$input." ".$hal." ".$species." \n";
close (TD);
#submit Ballgown
$command = "sbatch --time=06:00:00 -J RNAcode_".basename($input)." ".$bas.".sh ";
print $command,"\n";
$ret = `$command 2>&1`;
chomp $ret;


$ret=~/(\d+)/;

push(@job_dependencies,$1);
print $1,"\n";
push(@bamfiles,$bam_file);
      }
  }

exit(0);
foreach my $bam (@bamfiles)
  {
    my $outputFolder = $bam;
    $outputFolder =~ s/\/Aligned.noS.bam//;
    $outputFolder = $outputFolder."_All";
    $command = "sbatch --time=03:00:00 -J cuffquant".basename($outputFolder)." /home/cdieterich/scripts/cuffquant_cluster_strand.sh ".$bam." ".$cuffcmp_gtfFile." ".$outputFolder." ".$library_type;
    my $ret = `$command 2>&1`;
    #print $command,"\n";
    #print $outputFolder,"\n";
    chomp $ret;

    $ret=~/(\d+)/;
    push(@job_dependencies,$1);
    print "cuffquantAll".$1."\n";
  }

#do the cuffdiff now.

#my $JobDepString = join(":",@job_dependencies);
#$command = "sbatch --time=20:00:00 -p blade,himem --dependency=afterok:".$JobDepString." -J cuffmerge /home/cdieterich/scripts/cuffmerge_cluster.sh ".$gtfFile." ".$refGenome;
#my $ret = `$command 2>&1`;
#chomp $ret;
