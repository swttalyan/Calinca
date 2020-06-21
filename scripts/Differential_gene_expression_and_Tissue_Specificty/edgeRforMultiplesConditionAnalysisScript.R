#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
GeneCountFile <- args[1]
ContrastFile<-args[2]
## load the following module on cluster  module load R/3.3.0

rawdata <- read.csv(GeneCountFile,header=TRUE,row.names=1)

d<-read.table(ContrastFile,header=TRUE,sep="\t")


dir.create("Output/DifferentialExpression")
setwd("Output/DifferentialExpression")


library(edgeR)
y <- DGEList(counts=rawdata)
y <- calcNormFactors(y)
time<-factor(d$Time)
head(time)
genotype<-factor(d$Genotype)
head(genotype)
#time=c("4","4","4","4","4","4","12","12","12","12","12","12")
#genotype=c("het_ko","het_ko","het_ko","wt","wt","wt","het_ko","het_ko","het_ko","wt","wt","wt")
design <- model.matrix(~0 + time + genotype)
colnames(design)
y <- estimateGLMCommonDisp(y, design, verbose=TRUE)
y <- estimateGLMTrendedDisp(y, design)
y <- estimateGLMTagwiseDisp(y, design)
fit <- glmFit(y, design)
lrt <- glmLRT(fit,coef=3)
topTags(lrt)
FDR <- p.adjust(lrt$table$PValue, method="BH")
result<-cbind(lrt$table, FDR)
write.table(result, file="edgeR_likelihood_Matrix.txt",sep="\t")



#FDR <- p.adjust(lrt$table$PValue, method="BH")
#result<-cbind(lrt$table, FDR)
#write.table(result, file="edgeR_likelihood_Matrix_TS1.txt")



sum(FDR<0.05)




sum(FDR<0.05 & lrt$table$logFC>0.58)


sum(FDR<0.05 & lrt$table$logFC<(-0.58))


result[result$logFC>0.58 & FDR<0.05,]
up=result[result$logFC>0.58 & FDR<0.05,]
down=result[result$logFC<(-0.58) & FDR<0.05,]


write.table(up,"up_reg_edgeR_Genes.txt")
write.table(down,"down_reg_edgeR_Genes.txt")


quit()

