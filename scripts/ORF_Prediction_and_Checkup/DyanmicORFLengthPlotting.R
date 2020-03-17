#!/usr/bin/Rscript
## Collect file as argument
args = commandArgs(trailingOnly=TRUE)


# test if there is at least one argument: if not, return an err}

print(args)

######### Equation from ME Dinger et all Plos computational Biology, 2008
################### equation y=91.ln(x)-330
file<-args[1]
d<-read.table(file,head=T,sep="\t",stringsAsFactors=F)
x=c(0:8000)
y=c(0:600)
y=91*log(x)-330


N<-d[d$ORFStatus == 'noORF',]
Y<-d[d$ORFStatus == 'withORF',]

pdf("Rplot.pdf")


plot(Y$tTCONSlen.bp.,Y$ActualyORFlenfromInputFile.bp.,ylim=c(0,600),xlim=c(0,8000),typ="p",pch=18,col="GREEN",ylab="ORF length [bp]",xlab="Transcript length [bp]",main="ME Dinger et al Plot", sub="Red dots -> Potential protein coding Green dots-> Potential lncRNA")
lines(N$tTCONSlen.bp.,N$ActualyORFlenfromInputFile.bp.,ylim=c(0,600),xlim=c(0,8000),pch=20,col="RED",typ="p")
lines(y,typ="l",ylab="ORF length",xlab="Transcript length",lwd=2)

dev.off()

pdf("Density.pdf")

par(mfrow=c(2,1))
plot(density(Y$ActualyORFlenfromInputFile.bp.),col="GREEN",main="ORF corresponding to potential protein coding transcripts")
plot(density(N$ActualyORFlenfromInputFile.bp.),col="RED",main="ORF corresponding to potential non coding transcripts")

dev.off()
