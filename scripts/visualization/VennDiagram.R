## VennDiagram

library(VennDiagram)


# Define thresholds
padj_cutoff <- 0.05
lfc_cutoff <- 1

# Load DESeq2 results
res_L3 <- results(dds, name = "genotype_K36R_vs_HWT")
res_WD <- results(dds, list(c("genotype_K36R_vs_HWT", "tissueWD.genotypeK36R")))

# ----------------------------
# Extract DEG gene sets (with NA filtering)
# ----------------------------

# Upregulated (K36R > HWT)
up_L3 <- na.omit(rownames(res_L3)[res_L3$log2FoldChange > lfc_cutoff & res_L3$padj < padj_cutoff])
up_WD <- na.omit(rownames(res_WD)[res_WD$log2FoldChange > lfc_cutoff & res_WD$padj < padj_cutoff])

# Downregulated (K36R < HWT)
down_L3 <- na.omit(rownames(res_L3)[res_L3$log2FoldChange < -lfc_cutoff & res_L3$padj < padj_cutoff])
down_WD <- na.omit(rownames(res_WD)[res_WD$log2FoldChange < -lfc_cutoff & res_WD$padj < padj_cutoff])

# ----------------------------
# Print overlap counts
# ----------------------------

cat("⬆️ Shared Upregulated Genes (K36R > HWT):", length(intersect(up_L3, up_WD)), "\n")
cat("⬇️ Shared Downregulated Genes (K36R < HWT):", length(intersect(down_L3, down_WD)), "\n")

# ----------------------------
# Create Venn Diagrams
# ----------------------------

# Venn for Upregulated
venn.diagram(
        x = list("L3 Up" = up_L3, "WD Up" = up_WD),
        filename = "Venn_Upregulated.png",
        imagetype = "png",
        output = TRUE,
        height = 2000,
        width = 2000,
        resolution = 300,
        col = "black",
        fill = c("dodgerblue", "darkorange"),
        alpha = 0.5,
        cex = 1.5,
        fontface = "bold",
        cat.cex = 1.5,
        cat.fontface = "bold",
        main = "Upregulated Genes (K36R > HWT)"
)

# Venn for Downregulated
venn.diagram(
        x = list("L3 Down" = down_L3, "WD Down" = down_WD),
        filename = "Venn_Downregulated.png",
        imagetype = "png",
        output = TRUE,
        height = 2000,
        width = 2000,
        resolution = 300,
        col = "black",
        fill = c("mediumseagreen", "tomato"),
        alpha = 0.5,
        cex = 1.5,
        fontface = "bold",
        cat.cex = 1.5,
        cat.fontface = "bold",
        main = "Downregulated Genes (K36R < HWT)"
)

# ----------------------------
# Save gene lists (optional)
# ----------------------------

writeLines(up_L3, "Up_L3.txt")
writeLines(up_WD, "Up_WD.txt")
writeLines(down_L3, "Down_L3.txt")
writeLines(down_WD, "Down_WD.txt")
