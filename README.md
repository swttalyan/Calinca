## calinca
A work-flow for identification of known and novel lncRNA, potentially conserved and check for tissue expression

### Introduction


### Author/Support 


### Requirements/Dependencies
~~~~~~~~~~~~~
flexbar
samtools
bowtie2
STAR
StringTie
Samtools
gffcomp

~~~~~~~~~~~~~

### Work-flow Modules

### Step1: Read Processing and Mapping

Example command to run the Step1: perl scripts/Read_Processing_Mapping/workflow_RNAseq_PE_MPIZ_musMusculus_ENS90.pl samplefile.txt _1.fastq.gz _2.fastq.gz /prj/KFO329/index/contaminants  /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf
 /biodb/genomes/mus_musculus/GRCm38_90/star/


### Step2: Assembly and Transcript Quantification

Example command to run the Step2:perl scripts/Assembly_and_Transcript_Quantification/submit_StringTieQuant_homoSapiens_ENS90.pl BAMFilesLocation.txt

### Step3: ORF Prediction and Checkup


# kfo329
Workflow for discovery of lncRNA

The basic workflow involves the following steps:

* Read processing and mapping
* Read assembly and transcript abundance estimation
* ORF prediction, overlap with annotated ORFs and sequence conservation check
* Exon-intron / gene order conservation with CYNTENATOR

Read processing and mapping
---------------------------

CD has already implemented a workflow for this.

The master script is
`workflow_RNAseq_PE_MPIZ_musMusculus_ENS90.pl
`

This script has several dependencies.

`flexbar_paired_30.sh and linked module (binary)`

`remove_rRNA_bowtie2_paired.sh and linked module (binary)`

`STARalliance_circles_DCC_singlePass.sh and linked module (binary)`

to be continued

Read assembly and transcript abundance estimation
-------------------------------------------------

The master script is
`submit_StringTieQuant_homoSapiens_ENS90.pl`

It is called by inputting the absolute BAM file paths (no Makefile
this time). Please bear in mind that **mate** BAM files should not be
included.
Just the proper paired-end BAM files from STAR.

Again, there are several dependencies

> stringtie_cluster_Ballgown.sh
> scallop.sh
> cuffmerge_scallop_cluster.sh
> cuffquant_cluster_strand.sh


ORF prediction and checkup
--------------------------

The master script is
`workflow_lncRNA_discovery_KFO_musMusculus.pl`

It requires a list of candidate identifiers (TCONS_*) from cuffmerge,
which exceed an expression limit cutoff.

Most of the dependencies are satisifed throuch the Transdecoder
package.

Additional you need the scripts in this repo subfolder
>ORF_prediction_and_checkup


Conservation of gene order, structure, sequence, etc.
-------------------------------------------

Sequence conservation is currently checked with
`submit_RNAcode_musMusculus_KFO.pl`

it depends on `get_HAL_alignments_RNAcode.pl`

Differential gene expression of FSGS mouse data
------------------------------------------------
Read processing, mapping, transcript assembly and quantification has been performed by using the above script.
prepDE.py script from StringTie is use to calculate gene and transcript count.
Differential gene expression is calculated using DESeq2 
DESeqCommands.R 
Further the differential expressed genes are selected based on the following cutoff:
Padj<0.05
log2Foldchange>0.58
