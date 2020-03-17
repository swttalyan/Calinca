#!/usr/bin/perl
use File::Basename;

#my $geneID = shift @ARGV;
my $inputGTF = shift @ARGV;
my $refDB = shift @ARGV;
my $species = shift @ARGV;

#ok, we need to go genewise / batch wise
#gene_id "XLOC_000001";
#should be transcript ID

open(IN,$inputGTF) || die "Could not open input file";
my $of = basename($inputGTF);
open(OUTA,">results_".$of.".bed") || die "Could not open output bed file";

while(my $line = <IN>)
{
    chomp $line;
    next unless ($line =~ /transcript\_id\s\"(\S+)\"/);
    $geneID = $1;

    #print $geneID,"\n"
    #
    #write bed file
    @linearray = split(/\t+/,$line);
    $linearray[6]='+' if ($linearray[6] eq '.');
    open(OUT,">RNAcode_".$of.$geneID.".bed") || die "Could not open output file";
    print OUT $linearray[0],"\t",($linearray[3]-1),"\t",($linearray[4]-1),"\t",$geneID,"\t1000\t",$linearray[6],"\n";
    close(OUT);

#Aargh
#make sure that we load the module
#iteratively could work better
    
#--refGenome
#--refTargets
#hal2maf --onlyOrthologs --refGenome homo_sapiens --refTargets small.bed /biodb/alignments/NHP_8way_EnsEMBL/epo_8_primate_Ensembl85.hal output.maf
#luckily RNAcode seems to work with MAF data.

    system("rm -f ".$of.$geneID.".maf");
    system("hal2maf --onlyOrthologs --refGenome ".$species." --targetGenomes homo_sapiens,rattus_norvegicus,bos_taurus,canis_familiaris --refTargets RNAcode_".$of.$geneID.".bed ".$refDB." ".$of.$geneID.".maf");
    my $status = "";
    my $filename = $of.$geneID.".maf";

    if(-e $filename)
	{
	   my $size = (stat $filename)[7];
	   if($size>2000){

	    my $command = "RNAcode -n 1000 -t --stop-early --eps --eps-dir ".$of.$geneID."_epsdir -o ".$of.$geneID.".rnc ".$of.$geneID.".maf";
	    my $ret = `$command 2>&1`;
	    
	    
	    print $command,"\n";
	    print $ret,"\n";

	    #$of.$geneID.".rnc
	    
	    open(RES,$of.$geneID.".rnc") || die "Could not open result file";
	    

	    while(my $bla = <RES>)
	      {
		chomp $bla;
		my @arr = split(/\t+/,$bla);
		$arr[6] =~ s/$species\.//;

		print OUTA $arr[6],"\t",$arr[7],"\t",$arr[8],"\t",$geneID,"\t",$arr[10],"\t",$arr[1],"\n";
	      }

	    close(RES);
	    	  
	}
	  else
	    {
	      print OUTA $linearray[0],"\t",($linearray[3]-1),"\t",($linearray[4]-1),"\t",$geneID,"\t1000\t",$linearray[6],"\n";
	    }

	 }
    	   
	    system("rm -f ".$of.$geneID.".rnc");
            system("rm -f ".$of.$geneID.".maf");
            system("rm -f RNAcode_".$of.$geneID.".bed");
  }
close(OUTA);
close(IN); 

