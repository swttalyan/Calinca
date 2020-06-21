#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
GeneCountFile <- args[1]
ContrastFile<-args[2]

x <- read.csv(GeneCountFile,row.names="gene_id")
c<-read.table(ContrastFile,header=TRUE)
group<-c$Group

dir.create("Output/DifferentialExpression")
setwd("Output/DifferentialExpression")
## load the following module on cluster  module load R/3.3.0
#group <- factor(c(1,1,1,2,2,2))
library("edgeR")
y <- DGEList(counts=x,group=group)
y <- calcNormFactors(y)
design <- model.matrix(~group)
y <- estimateDisp(y,design)


fit <- glmQLFit(y,design)
qlf <- glmQLFTest(fit,coef=2)
topTags(qlf)

fit <- glmFit(y,design)
lrt <- glmLRT(fit,coef=2)
topTags(lrt)

FDR <- p.adjust(lrt$table$PValue, method="BH")
result<-cbind(lrt$table, FDR)
write.table(result, file="edgeR_likelihood_Matrix.txt")



sum(FDR<0.05)




sum(FDR<0.05 & lrt$table$logFC>0.58)


sum(FDR<0.05 & lrt$table$logFC<(-0.58))


result[result$logFC>0.58 & FDR<0.05,]
up=result[result$logFC>0.58 & FDR<0.05,]
down=result[result$logFC<(-0.58) & FDR<0.05,]


write.table(up,"up_reg_edgeR.txt")
write.table(down,"down_reg_edgeR.txt")

############## for the test condition second
#x <- read.csv("../DEAnalysis/gene_count_matrix_TS2.csv",row.names="gene_id")
#group <- factor(c(1,1,1,2,2,2))

#y <- DGEList(counts=x,group=group)
#y <- calcNormFactors(y)
#design <- model.matrix(~group)
#y <- estimateDisp(y,design)


#fit <- glmQLFit(y,design)
#qlf <- glmQLFTest(fit,coef=2)
#topTags(qlf)

#fit <- glmFit(y,design)
#lrt <- glmLRT(fit,coef=2)
#topTags(lrt)

#FDR <- p.adjust(lrt$table$PValue, method="BH")
#result<-cbind(lrt$table, FDR)
#write.table(result, file="edgeR_likelihood_Matrix_TS2.txt")



#sum(FDR<0.05)




#sum(FDR<0.05 & lrt$table$logFC>0.58)


#sum(FDR<0.05 & lrt$table$logFC<(-0.58))


#result[result$logFC>0.58 & FDR<0.05,]
#up=result[result$logFC>0.58 & FDR<0.05,]
#down=result[result$logFC<(-0.58) & FDR<0.05,]


#write.table(up,"up_reg_edgeR_TS2.txt")
#write.table(down,"down_reg_edgeR_TS2.txt")
