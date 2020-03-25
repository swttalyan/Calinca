## calinca
A work-flow for identification of known and novel podocytes lncRNAs, potentially conserved in human and check for tissue specific expression.

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
cufflinks
~~~~~~~~~~~~~

### KFO Work-flow Modules

The basic workflow involves the following steps:

* Read processing and mapping
* Transcript assembly and abundance estimation
* ORF prediction, check and selection of lncRNA candidates
* conservation and expression in human
* Exon-intron / gene order conservation with CYNTENATOR


### Step 1: Read Processing and Mapping

Example command to run the Step1: perl scripts/Read_Processing_Mapping/workflow_RNAseq_PE_MPIZ_musMusculus_ENS90.pl samplefile.txt _1.fastq.gz _2.fastq.gz /prj/KFO329/index/contaminants  /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf
 /biodb/genomes/mus_musculus/GRCm38_90/star/


### Step 2: Assembly and Transcript Quantification

Example command to run the Step2:perl scripts/Assembly_and_Transcript_Quantification/submit_StringTieQuant_homoSapiens_ENS90.pl BAMFilesLocation.txt

### Step 3: ORF Prediction and Checkup



### Step 4: Sequence and gene order conservation


### Step 5: Differential gene expression of FSGS mouse data
------------------------------------------------
prepDE.py script from StringTie is use to calculate gene and transcript count.
Differential gene expression is calculated using DESeq2 
edgeR.R 
Further the differential expressed genes are selected based on the following cutoff:
Padj<0.05
log2Foldchange>0.58
