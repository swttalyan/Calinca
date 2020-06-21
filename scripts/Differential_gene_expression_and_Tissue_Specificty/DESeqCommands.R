## load library
library("DESeq2")

##Import gene count data for test condition 2 (4 week KO vs 4 week WT)
countData <- as.matrix(read.csv("/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/FSGSMouseAnalysis/DEAnalysis/gene_count_matrix_TS1.csv", row.names="gene_id",sep="\t")) #Import the count matrix.
colData <- read.csv("/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/FSGSMouseAnalysis/DEAnalysis/Sample1.txt", sep="\t", row.names=1) #Import the phenotype
all(rownames(colData) %in% colnames(countData))
dds <- DESeqDataSetFromMatrix(countData = countData, colData = colData, design = ~ Type)
dds <- DESeq(dds)
res <- results(dds) #to obtain the mean expression, the p-value of the test etc.
sorted_res = (resOrdered <- res[order(res$padj), ]) #to sort the p-values by their value (smallest to largest)
head(sorted_res)
Deg <- cbind(rownames(sorted_res), sorted_res$baseMean,sorted_res$log2FoldChange,sorted_res$lfcSE,sorted_res$stat,sorted_res$pvalue,sorted_res$padj)
write.table(Deg,"/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/FSGSMouseAnalysis/DEAnalysis/DEG_Matrix_TS1.txt")



##Import gene count data for test condition 2 (12 week KO vs 12 week WT)
countData <- as.matrix(read.csv("/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/FSGSMouseAnalysis/DEAnalysis/gene_count_matrix_TS2.csv", row.names="gene_id",sep="\t")) #Import the count matrix.
colData <- read.csv("/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/FSGSMouseAnalysis/DEAnalysis/Sample2.txt", sep="\t", row.names=1) #Import the phenotype
all(rownames(colData) %in% colnames(countData))
dds <- DESeqDataSetFromMatrix(countData = countData, colData = colData, design = ~ Type)
dds <- DESeq(dds)
res <- results(dds) #to obtain the mean expression, the p-value of the test etc.
sorted_res = (resOrdered <- res[order(res$padj), ]) #to sort the p-values by their value (smallest to largest)
head(sorted_res)
Deg <- cbind(rownames(sorted_res), sorted_res$baseMean,sorted_res$log2FoldChange,sorted_res$lfcSE,sorted_res$stat,sorted_res$pvalue,sorted_res$padj)
write.table(Deg,"/prj/KFO329/WP1-Podocyte_enriched_lncRNAs/FSGSMouseAnalysis/DEAnalysis/DEG_Matrix_TS2.txt")


