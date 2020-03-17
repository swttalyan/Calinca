#!/usr/bin/perl

#Necessary steps
#4. Candidate selection: removing long- and short- ORFs, length and FPKM selection
#cuffnorm_slurm.sh - optional
#srun select_novel_candidates.sh
#transdecoder.sh
#srun split_gtf_LORF.sh
#srun get_alignments.sh
#RNAcode_array.sh

use File::Basename;

my $wdir = shift @ARGV;

my @files;

system("mkdir -p ".$wdir) unless (-d $wdir);
chdir($wdir) || die "Could not change to wdir";

#system("mkdir -p cuffnorm");
system("mkdir -p transdecoder");
system("mkdir -p RNAcode");

my $mergedGTF = "/prj/Roman_Mueller/KFO/Public_SRA/workflow_PE_WP1/mapping/merged_asm/merged.gtf";
my $refGenomeFasta = "/biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa";
my $refGTF = "/biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf";

#software path
my $TDPATH = "/biosw/transdecoder/2.0.1"; #replace via module system

open(OUT,">Makefile");
print OUT "SHELL := /bin/bash\n\n";
print OUT "all: SELECT TRANSDECODER RNA_CODE\n\n";
#RNACODE

print OUT "SELECT:candidateIDs.gtf transdecoder/transcripts.gff3 transdecoder/transcripts.fasta\n\n";

print OUT "TRANSDECODER: transdecoder/transcripts.fasta transdecoder/transcripts.fasta.transdecoder_dir/longest_orfs.cds transdecoder/transcripts.fasta.transdecoder.genome.gff3\n\n";

#my @tmp = map {"RNAcode/RNAcode_".$_."_noORF.gtf"} keys %seqID;

print OUT "RNA_CODE: RNAcode/noORF.gtf "."\n\n";

print OUT "candidateIDs.gtf : candidates.txt $mergedGTF \n";
print OUT "\tsrun --time=1:00:00 -n1 -N1 -c1 perl /home/cdieterich/scripts/select_from_GTF.pl candidates.txt $mergedGTF > candidateIDs.gtf\n";

#candidate selection done and found under cuffnorm/candidateIDs.gtf

open(TD,">transdecoder/select_candidates.sh") || die "Could not generate R script";
print TD "#!/bin/bash\n";
print TD "module unload transdecoder\n";
print TD "module load transdecoder/2.0.1 \n";
print TD $TDPATH."/util/cufflinks_gtf_to_alignment_gff3.pl candidateIDs.gtf > transdecoder/transcripts.gff3\n";
close(TD);

system("chmod 755 transdecoder/select_candidates.sh");

print OUT "transdecoder/transcripts.gff3 : candidateIDs.gtf\n";
print OUT "\tsrun --time=1:00:00 -n1 -N1 -c1 transdecoder/select_candidates.sh\n\n";

open(TD,">transdecoder/make_fasta.sh") || die "Could not generate R script";
print TD "#!/bin/bash\n";
print TD $TDPATH."/util/cufflinks_gtf_genome_to_cdna_fasta.pl candidateIDs.gtf ".$refGenomeFasta." > transdecoder/transcripts.fasta\n";
close(TD);

system("chmod 755 transdecoder/make_fasta.sh");

print OUT "transdecoder/transcripts.fasta : candidateIDs.gtf\n";
print OUT "\tsrun --time=1:00:00 --mem=20g -n1 -N1 -c1 transdecoder/make_fasta.sh\n\n";

open(TD,">transdecoder/longOrfs.sh") || die "Could not generate R script";
print TD "#!/bin/bash\n";
print TD "cd transdecoder\n";
print TD $TDPATH."/TransDecoder.LongOrfs -m 60 -t transcripts.fasta\n";
close(TD);

system("chmod 755 transdecoder/longOrfs.sh");

print OUT "transdecoder/transcripts.fasta.transdecoder_dir/longest_orfs.cds : transdecoder/transcripts.fasta\n";
print OUT "\tsrun --time=1:00:00 -n1 -N1 -c1 --mem=8g transdecoder/longOrfs.sh\n\n";

open(TD,">transdecoder/predictOrfs.sh") || die "Could not generate R script";
print TD "#!/bin/bash\n";
print TD "cd transdecoder\n";
print TD $TDPATH."/TransDecoder.Predict -t transcripts.fasta\n";
close(TD);

system("chmod 755 transdecoder/predictOrfs.sh");

print OUT "transdecoder/transcripts.fasta.transdecoder.mRNA : transdecoder/transcripts.fasta.transdecoder_dir/longest_orfs.cds\n";
print OUT "\tsrun --time=1:00:00 -n1 -N1 -c1 transdecoder/predictOrfs.sh\n\n";

#${TDPATH}/util/cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff3 transcripts.gff3 transcripts.fasta > transcripts.fasta.transdecoder.genome.gff3


open(TD,">transdecoder/coordinates.sh") || die "Could not generate R script";
print TD "#!/bin/bash\n";
print TD "cd transdecoder\n";
print TD $TDPATH."/util/cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff3 transcripts.gff3 transcripts.fasta > transcripts.fasta.transdecoder.genome.gff3\n";
close(TD);

system("chmod 755 transdecoder/coordinates.sh");

print OUT "transdecoder/transcripts.fasta.transdecoder.genome.gff3 : transdecoder/transcripts.fasta.transdecoder.mRNA\n";
print OUT "\tsrun --time=1:00:00 -n1 -N1 -c1 --mem=8g  transdecoder/coordinates.sh\n\n";
#close(OUT);

open(TD,">RNAcode/select_noORF.sh") || die "Could not generate shell script";
print TD "#!/bin/bash\n";
print TD "cd RNAcode\n";
print TD "cut -f 1 ../transdecoder/transcripts.fasta.transdecoder.bed |sort -u > orf_transdecoder_ids.txt\n";
print TD "/home/cdieterich/scripts/disselect_from_GTF.pl orf_transdecoder_ids.txt ../candidateIDs.gtf > noORF.gtf\n";
print TD $TDPATH."/util/cufflinks_gtf_genome_to_cdna_fasta.pl noORF.gtf ".$refGenomeFasta." > noORF.fasta\n";
print TD "/home/cdieterich/scripts/chunks_from_GTF.pl noORF.gtf 100\n";
close(TD);

system("chmod 755 RNAcode/select_noORF.sh");

print OUT "RNAcode/noORF.gtf : transdecoder/transcripts.fasta.transdecoder.genome.gff3\n";
print OUT "\tsrun --time=1:00:00 -n1 -N1 -c1 --mem=8g  RNAcode/select_noORF.sh\n\n";

#bla - transcripts.fasta.transdecoder.bed
#check for ORFs
#select_from_GTF.pl
#contrast with candidateIDs.gtf
#split of noORF

close(OUT);



#close(OUT);

#replace with new HAL based approach
#array job etc.
