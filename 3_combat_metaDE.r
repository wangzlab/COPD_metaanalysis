## This R script is used to perform combat normalization and MetaDE meta-analysis for the processed transcriptome data ##
## The input data is "all.txt", which is a concatenated matrix of normalized expression values of all genes (in rows) and all samples (in columns) ##

library(bnstruct)
data<-read.table("all.txt",header=TRUE,row.names=1,check.names=F,sep="\t")
data_impute<-knn.impute(as.matrix(data),k=10,cat.var=1:ncol(data),to.impute=1:nrow(data),using=1:nrow(data))
write.table(data_impute,file="all_imputed.txt",append=FALSE,quote=FALSE,sep="\t")

library(sva)
data<-read.table("all_imputed.txt",header=TRUE,row.names=1,check.names=F,sep="\t")
meta<-read.table("all_metadata.txt",header=TRUE,row.names=1,check.name=F,sep="\t")
batch<-meta$batch
all_combat<-ComBat(as.matrix(data_impute),batch,mod=NULL,par.prior=TRUE,prior.plots=FALSE)
write.table(all_combat,file="all_combat.txt",append=FALSE,quote=FALSE,sep="\t")
pca<-prcomp(t(all_combat))
write.table(pca$x,file="pca.txt",append=FALSE,quote=FALSE,sep="\t")
pca<-prcomp(t(data))
write.table(pca$x,file="pca2.txt",append=FALSE,quote=FALSE,sep="\t")

ggplot(pca,aes(pca$tPC1,pca$tPC2))+geom_point(size=2,aes(col=pca$study))+scale_color_manual(values=c("#003300","#339999","#3399CC","#CC00CC","#CC0033","#CC6600","#ffcccc","#996699","#ffcc33","#3300ff","#9900ff","#fff666","#333300","#336600","#0099cc","#336666","#ccffcc","#990033","#660066","#3300cc","#006600","#99cc00","#000000","#66FFFF","#FF00FF","#666666"))
ggplot(pca,aes(pca$tPC1,pca$tPC2))+geom_point(aes(col=pca$disease))

library(MetaDE)
study.names<-c("GSE103174", "GSE106986", "GSE112260", "GSE11784", "GSE119040", "GSE11906", "GSE12472", "GSE13896", "GSE16972", "GSE37147", "GSE37768", "GSE38974", "GSE47460", "GSE56341", "GSE57148", "GSE73395", "GSE76925", "GSE8581", "GSE86064")
data.raw<-MetaDE.Read(study.names,skip=rep(1,25),via="txt",matched=T,log=F)
data.merged<-MetaDE.merge(data.raw)
ind.res1<-ind.analysis(data.merged,ind.method=rep("modt",25),nperm=300,tail="abs")
ind.res2<-ind.cal.ES(data.merged,paired=rep(F,25),nperm=300)
res2<-MetaDE.ES(ind.res2,meta.method="REM")

MetaDE.res1<-MetaDE.rawdata(data.merged,ind.method=rep("modt",4),paired=rep(F,4),meta.method="REM",nperm=300)
write.table(MetaDE.res1$meta.analysis$FDR,file='metaFDR.txt',append=FALSE,sep="\t",quote=FALSE)
write.table(MetaDE.res1$meta.analysis$zval,file='metaZval.txt',append=FALSE,sep="\t",quote=FALSE)
write.table(MetaDE.res1$meta.analysis$pval,file='metaPval.txt',append=FALSE,sep="\t",quote=FALSE)
saveRDS(MetaDE.res1,file="Meta.RDS")
