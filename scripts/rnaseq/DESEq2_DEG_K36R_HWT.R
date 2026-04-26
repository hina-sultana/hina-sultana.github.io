setwd("/Users/hina/dropbox/7_Big_Transcriptomics_Project/Mike_Meers_data")
counts <- read.delim("salmon.merged.gene_counts.tsv", row.names = 1)
head(counts)

library(dplyr)
library(tibble)
counts_clean <- counts %>%
        select(-gene_name, -HWT_WD_Rep2)

counts_mat <- as.matrix(counts_clean)
mode(counts_mat) <- "numeric"
counts_mat_rounded <- round(counts_mat)

library(DESeq2)
library(tidyverse)

colnames(counts_mat)

coldata <- data.frame(
        row.names = colnames(counts_mat),  # use column names as sample names
        tissue = c("L3", "L3", "L3",        # HWT_L3
                   "WD", "WD",              # HWT_WD (only 2 reps now)
                   "L3", "L3", "L3",        # K36R_L3
                   "WD", "WD", "WD"),       # K36R_WD
        genotype = c("HWT", "HWT", "HWT",   # HWT_L3
                     "HWT", "HWT",          # HWT_WD
                     "K36R", "K36R", "K36R",# K36R_L3
                     "K36R", "K36R", "K36R")# K36R_WD
)

coldata$tissue <- factor(coldata$tissue)
coldata$genotype <- factor(coldata$genotype)
head(coldata)
coldata
head(counts_mat)

all(rownames(coldata) == colnames(counts_mat))

dds <- DESeqDataSetFromMatrix(
        countData = counts_mat_rounded,
        colData = coldata,
        design = ~ tissue + genotype + tissue:genotype
)
## dds:17582

dds <- dds[rowSums(counts(dds)) >= 10, ]
## dds: 14702
dds <- DESeq(dds)

### genotype effect within each tissue
levels(coldata$tissue)
levels(coldata$genotype)

##1. Effect of Mutation (K36R vs HWT) in Each Tissue
## A. In L3 tissue
## Since "L3" is the reference tissue, the genotype effect here is directly captured by the main genotype
res_K36R_vs_HWT_L3 <- results(dds, name = "genotype_K36R_vs_HWT")

##In WD tissue
res_K36R_vs_HWT_WD <- results(dds, list(c("genotype_K36R_vs_HWT", "tissueWD.genotypeK36R")))

##2. Interaction Term
##This tests whether the effect of mutation differs between L3 and WD:
res_interaction <- results(dds, name = "tissueWD.genotypeK36R")

## Export Results
write.csv(as.data.frame(res_K36R_vs_HWT_L3), "DESeq2_K36R_vs_HWT_L3.csv")
write.csv(as.data.frame(res_K36R_vs_HWT_WD), "DESeq2_K36R_vs_HWT_WD.csv")
write.csv(as.data.frame(res_interaction), "DESeq2_K36R_Interaction_Term.csv")
