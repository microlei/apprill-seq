# Input: seqtab (output/seqtab_nochim.rds)
# Output: otus (output/STT2020_ASVs.txt), taxonomy (output/STT2020_taxonomy.txt), ASVseqs (output/STT2020_ASVsequences.txt)
# Params: samples (SAMPLES)

sink(snakemake@log[[1]])

cat("Beginning output of taxonomy assignment \n")
library(dada2)

load(file=snakemake@input[['seqtab']]) #note this loads seqtab.nochim

cat("Assigning taxonomy\n")
taxa <- assignTaxonomy(seqtab.nochim, snakemake@config[['taxadb']], multithread=TRUE, minBoot = snakemake@config[['minBoot']])
taxa <- addSpecies(taxa, snakemake@config[['speciesdb']], verbose =TRUE, allowMultiple = 3)

taxa.print <- taxa
rownames(taxa.print) <- NULL
head(taxa.print)

cat("Finished training set! \n")

cat("Making output ASV table...\n")
otus <- seqtab.nochim
taxonomy <- taxa
idx <- match(rownames(taxonomy), colnames(otus))
otus <- otus[,idx]

cat("Making asv table with ", dim(seqtab.nochim)[2], " sequences.\n")
ASVseqs <- data.frame("asv" = paste0("ASV", seq(from = 1, to = dim(seqtab.nochim)[2], by = 1)), "sequence" = rownames(taxa))
colnames(otus) <- ASVseqs$asv
otus <- t(otus)
rownames(taxonomy) <- ASVseqs$asv
colnames(otus) <- snakemake@params[['samples']] #make sure that params are listed in the rule!
cat("Glance at taxonomy\n")
head(taxonomy)
cat("==========\n")
cat("Glance at ASVs\n")
head(otus)

# making the outputs
write.table(otus, file=snakemake@output[['otus']], sep = '\t', row.names=TRUE, col.names =TRUE)
write.table(taxonomy, file=snakemake@output[['taxonomy']], sep = '\t', row.names=TRUE, col.names = TRUE)
write.table(ASVseqs, file=snakemake@output[['ASVseqs']], sep = '\t', row.names=TRUE, col.names=TRUE)