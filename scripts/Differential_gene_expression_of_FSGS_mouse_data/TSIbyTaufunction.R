a<-as.matrix(read.table("pod_glom_kidney_allGenesFPKM.txt",sep="\t",row.names=1,as.is=TRUE,header=TRUE))

#a1 <- a               # expression matrix
m <- 3-1             # No of tissues - 1
#rownames(a1) <- a[,1]
#a1 <- a1[,-1]
a <- round(a,3)
dim1 <- dim(a)[1]
s <- matrix(0,nrow=dim(a)[1],ncol=2, dimnames = list(rownames(a), c("Tissue_specific_index","Tissue_name")))

for(i in 1:dim1){ 
  s[i,1] <- ( sum( 1 - a[i,]/ max(a[i,]))  ) / m   
  s[i,2] <- names(which.max(a[i,]))
  }
s2 <- subset(s,s[,1]>0.9)
table(s2[,2])
dim(s2)
write.table(s, file="tissue_specific_data_for_tau_allGenes.txt",row.names=TRUE, sep="\t", quote= FALSE)

