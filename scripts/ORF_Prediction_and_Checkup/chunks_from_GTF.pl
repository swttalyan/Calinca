#!/usr/bin/perl

my ($noORF,$chunk) = @ARGV[0..1];

$chunk |= 100;

my %h_id;

open(IN,$noORF);
while(<IN>)
  {
    chomp;
    next unless /(TCONS\_\d+)/;
    $h_id{$1}.=$_."\n";
  }
close(IN);

my @tmp = keys %h_id;
#chunk size
for(my $t=0;$t<@tmp;$t+=$chunk)
  {
    open(OUT,">batch_".$t."_".$noORF);
    for(my $k=$t;$k<($t+$chunk);$k++)
      {
	print OUT $h_id{$tmp[$k]} if ($tmp[$k]);
      }
    close(OUT);
  }


