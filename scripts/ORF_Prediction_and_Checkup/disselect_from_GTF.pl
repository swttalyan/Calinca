#!/usr/bin/perl

my ($ids,$f) = @ARGV[0..1];

my %h_id;

open(IN,$ids);
while(<IN>)
  {
    chomp;
    next unless /(TCONS\_\d+)/;
    $h_id{$1}=1;
  }
close(IN);

open(GTF,$f);
while(<GTF>)
  {
next unless /transcript\_id\s+\"(TCONS\_\d+)/;
print unless ($h_id{$1});
  }
close(GTF);
