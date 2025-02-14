library(DESeq2)
library(SummarizedExperiment)
library(crayon)

etapas <- c('ctrl', 'stagei', 'stageii','stageiii','stageiv')

for (etapa in etapas) {
  print(etapa)
  f <- paste0('Results/Expression/kidney-',etapa,'.tsv')
  expr <- read.table(file = f, sep = '\t', header = TRUE)
  if (etapa == 'ctrl') genes <- expr$gene
  expr <- expr[-1]
  if (etapa == 'ctrl'){
    countData <- expr
    condition <- rep(etapa,ncol(expr))
  }else{
    countData <- cbind(countData,expr)  
    condition <- c(condition,rep(etapa,ncol(expr)))
  }
}

condition <- as.factor(condition)
colData <- DataFrame(etapa=condition, row.names=colnames(countData))
se <- SummarizedExperiment(assays=as.matrix(round(countData)), colData=colData,
                           rowData=DataFrame(ensembleid=genes))
dds <- DESeqDataSet(se, ~ etapa)
dds <- DESeq(dds, test="LRT", reduced=~1) #ANODEV

# model.matrix(~condition)
resultsNames(dds)

x <- list()
x.names <- list()
combs <- combn(etapas,2) #combinaciones de etapas
for (comb in 1:ncol(combs)){
  cname <- paste0(combs[,comb][2],' - ',combs[,comb][1])
  print(paste0("Contrast: ",cname))
  res <- results(dds, contrast=c("etapa", combs[,comb][2], combs[,comb][1]))
  rownames(res) <- genes
  filtro <- res[(res$padj < 0.05) & (res$log2FoldChange < -0.5),]
  # summary(res)
  print(paste0("Underexpressed genes: ", nrow(filtro)))
  gs <- rownames(filtro)
  x[[comb]] <- gs
  x.names[[comb]] <- cname
}


# dir.create("Results/contrasts", recursive = TRUE)
cat(red$bold("ALL-Contrast Intersection\n"))
s <- paste0(x.names[[1]])
for (comb in 2:ncol(combs)){
  # print(paste0("Adding contrast: ", comb))
  s <- paste0(s, " , ", x.names[[comb]])
  cat(green("Set of contrasts intersected (", comb, ") :\n" ))
  print(s)
  l<- Reduce(intersect,x[1:comb])
  print(paste0("Genes of intersection: ", length(l)))
  if(length(l) == 2){
    bestgene <- l
  }
  # fname <- paste0("Results/contrasts/comb",comb,'.csv')
  # write.table(l,fname)
}
cat(green("Gene with more intersections: \n"))
cat(black$bgWhite$bold(bestgene[1]),",",black$bgWhite$bold(bestgene[2]),"\n")



# print("INTERSECCION CONTRASTES ENFERMOS")
# for (comb in 6:ncol(combs)){
#   l<- Reduce(intersect,x[5:comb])
#   print(paste0("Numero de contrastes: 5:", comb))
#   print(length(l))
# }
cat(red$bold("Only-ccRC-Contrast Intersection\n"))
s <- paste0(x.names[[5]])
for (comb in 6:ncol(combs)){
  s <- paste0(s, " , ", x.names[[comb]])
  cat(green("Set of contrasts intersected (", comb, ") :\n" ))
  print(s)
  l<- Reduce(intersect,x[1:comb])
  print(paste0("Genes of intersection: ", length(l)))
  if(length(l) == 2){
    bestgene <- l
  }
}
cat(green("Gene with more intersections: \n"))
cat(black$bgWhite$bold(bestgene[1]),",",black$bgWhite$bold(bestgene[2]),"\n")






####################################
#### END
####################################









# expr1 <- read.table(file = 'Results/Expression/kidney-ctrl.tsv', sep = '\t', header = TRUE)
# genes <- expr1$gene
# expr1 <- expr1[-1]
# condition <- rep("ctrl",ncol(expr1))
# expr2 <- read.table(file = 'Results/Expression/kidney-stagei.tsv', sep = '\t', header = TRUE)
# expr2 <- expr2[-1]
# countData <- cbind(expr1,expr2)
# condition <- c(condition,rep("stagei",ncol(expr2)))
# expr3 <- read.table(file = 'Results/Expression/kidney-stageii.tsv', sep = '\t', header = TRUE)
# expr3 <- expr3[-1]
# countData <- cbind(countData,expr3)
# condition <- c(condition,rep("stageii",ncol(expr3)))
# condition <- as.factor(condition)
# colData <- DataFrame(etapa=condition, row.names=colnames(countData))
# se <- SummarizedExperiment(assays=as.matrix(round(countData)), colData=colData)
# dds <- DESeqDataSet(se, ~ etapa)
# # model.matrix(~condition)
# 
# dds <- DESeq(dds, test="LRT", reduced=~1)
# resultsNames(dds)
# # res <- results(dds)
# # summary(res)
# 
# res <- results(dds, contrast=c("etapa", "ctrl", "stagei"))
# summary(res)
# res[(res$padj < 0.05) & (res$log2FoldChange > 1.0),]
# res <- results(dds, contrast=c("etapa", "ctrl", "stageii"))
# summary(res)
# res[(res$padj < 0.05) & (res$log2FoldChange > 1.0),]
# res <- results(dds, contrast=c("etapa", "stagei", "stageii"))
# summary(res)
# res[(res$padj < 0.05) & (res$log2FoldChange > 1.0),]
# res <- results(dds, contrast=c("etapa", "stageii", "stageii"))
# summary(res)
# res[(res$padj < 0.05) & (res$log2FoldChange > 1.0),]
