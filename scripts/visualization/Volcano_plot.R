#### Volcano Plot Template

install.packages("cowplot")


library(cowplot)
library(DESeq2)
library(EnhancedVolcano)
library(ggplot2)


install.packages("patchwork")
library(patchwork)



# Function to count DEGs
count_DEGs <- function(res, lfc = 1, padj_cutoff = 0.05) {
        res_df <- as.data.frame(res)
        up <- sum(res_df$log2FoldChange > lfc & res_df$padj < padj_cutoff, na.rm = TRUE)
        down <- sum(res_df$log2FoldChange < -lfc & res_df$padj < padj_cutoff, na.rm = TRUE)
        total <- sum(res_df$padj < padj_cutoff, na.rm = TRUE)
        return(list(up = up, down = down, total = total))
}

# Function to generate volcano plot with title and subtitle using patchwork
plot_volcano_with_subtitle <- function(res, title, lfc = 1, padj_cutoff = 0.05) {
        deg_stats <- count_DEGs(res, lfc, padj_cutoff)
        
        subtitle_text <- paste0(
                "DEGs (padj < ", padj_cutoff, ", |log2FC| > ", lfc, "): ",
                deg_stats$total, " total | ",
                deg_stats$up, " upregulated | ",
                deg_stats$down, " downregulated"
        )
        
        volcano <- EnhancedVolcano(res,
                                   lab = rownames(res),
                                   x = 'log2FoldChange',
                                   y = 'padj',
                                   title = NULL,
                                   subtitle = NULL,
                                   pCutoff = padj_cutoff,
                                   FCcutoff = lfc,
                                   pointSize = 1.0,
                                   labSize = 1.5,
                                   legendPosition = 'bottom',
                                   colAlpha = 0.75)
        
        # Custom title and subtitle plots
        title_plot <- ggplot() + 
                annotate("text", x = 0, y = 0, label = title, size = 5.5, fontface = "bold") +
                theme_void()
        
        subtitle_plot <- ggplot() + 
                annotate("text", x = 0, y = 0, label = subtitle_text, size = 3.5) +  # Smaller subtitle
                theme_void()
        
        # Combine using patchwork
        final_plot <- title_plot / subtitle_plot / volcano +
                plot_layout(heights = c(0.08, 0.08, 1))
        
        return(final_plot)
}

# 1. K36R vs HWT in L3
res_L3 <- results(dds, name = "genotype_K36R_vs_HWT")
p1 <- plot_volcano_with_subtitle(res_L3, "K36R vs HWT (L3)")
ggsave("Volcano_L3.png", plot = p1, width = 7, height = 9, dpi = 300)

# 2. K36R vs HWT in WD
res_WD <- results(dds, list(c("genotype_K36R_vs_HWT", "tissueWD.genotypeK36R")))
p2 <- plot_volcano_with_subtitle(res_WD, "K36R vs HWT (WD)")
ggsave("Volcano_WD.png", plot = p2, width = 7, height = 9, dpi = 300)

# 3. Interaction Term
res_interaction <- results(dds, name = "tissueWD.genotypeK36R")
p3 <- plot_volcano_with_subtitle(res_interaction, "Interaction: K36R Effect (WD vs L3)")
ggsave("Volcano_Interaction.png", plot = p3, width = 7, height = 9, dpi = 300)