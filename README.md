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
gffread
transdecoder5.5.0
BLAST
Cyntenator
R
~~~~~~~~~~~~~

### KFO Work-flow Modules

The basic workflow involves the following steps:

* Read processing and mapping
* Transcript assembly and abundance estimation
* ORF prediction, check and selection of lncRNA candidates
* Exon-intron / gene order conservation with CYNTENATOR
* Differential regulation of Genes and their Tissue specificty index calculation


### Step 1: Read Processing and Mapping
------------------------------------------------
Example command to run Step1: perl scripts/Read_Processing_Mapping/workflow_RNAseq_PE_MPIZ_musMusculus_ENS90.pl samplefile.txt _1.fastq.gz _2.fastq.gz /prj/KFO329/index/contaminants  /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf
 /biodb/genomes/mus_musculus/GRCm38_90/star/


### Step 2: Assembly and Transcript Quantification
------------------------------------------------
Example command to run Step2:perl scripts/Assembly_and_Transcript_Quantification/submit_StringTieQuant_homoSapiens_ENS90.pl BAMFilesForTxAssembly.txt /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa fr-firststrand BAMFilesForTxQuantifications.txt


### Step 3: ORF Prediction and Checkup
------------------------------------------------
Example command to run Step3: perl scripts/ORF_Prediction_and_Checkup/workflow_lncRNA_discovery_KFO_musMusculus.pl SelectedCandidates.gtf  /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa


### Step 4: Sequence and gene order conservation
------------------------------------------------
Example command to run Step4: perl scripts/Sequence_And_Synteny_Conservation/Sequence_And_Synteny_Conservation_Workflow.pl merged.gtf merged.fasta /biodb/genomes/mus_musculus/GRCm38_90/GRCm38.90.gtf /biodb/genomes/mus_musculus/GRCm38_90/GRCm38_90.fa /biodb/genomes/homo_sapiens/GRCh38_90/GRCh38.90.gtf /biodb/genomes/homo_sapiens/GRCh38_90/GRCh38_90.fa 


### Step 5: Differential gene expression and Tissue Specificty
------------------------------------------------

Example Command to run Tissue Specificity Script:  Rscript scripts/Enrichment_In_Tissue/TSIbyTaufunctiontmp.R pod_glom_kidney_allGenesFPKM.txt

python prepDE.py -i sample_lst.txt
NOTE:: prepDE.py script from StringTie is use to calculate gene and transcript count.

Differential gene expression is calculated using DESeq2 

for Single condition: Rscript edgeRScript.R gene_count_matrix_TS1.csv Contrast.txt
For multi conditions: Rscript edgeRforMultiplesConditionAnalysisScript.R gene_count_matrix_Combined.csv ContrastMultipleConditions.txt  

For this step the examples file used as input for the scripts are also provided in the folder for running.

NOTE:: Differential expressed genes are selected based on the following cutoff:
Padj<0.05
log2Foldchange>0.58
