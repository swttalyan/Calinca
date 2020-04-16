#`cut -f1 human_mouse_genes_alignments1.txt | sort -u >1.txt`;

#`cut -f1 mouse_human_genes_alignments1.txt | sort -u >2.txt`;



open (FH,"1.txt");
@file=<FH>;
close FH;
open (F1,">human_mouse_genes_5hits.blast");
foreach $line (@file)
{
chomp $line;
$match=`grep $line human_mouse_genes_alignments1.txt | sort -k3,3 -g -r | head -5`; chomp $match;
print F1 $match."\n";

}

close F1;
=head
open (FH,"2.txt");
@file=<FH>;
close FH;
open (FHH,">mouse_human_genes_5hits.blast");
foreach $line (@file)
{
chomp $line;
$match=`grep $line mouse_human_genes_alignments1.txt | sort -k3,3 -g -r | head -5`; chomp $match;
print FHH $match."\n";

}
close FHH;
