## GO Analysis


# Load required packages
install.packages("BiocManager")
BiocManager::install("clusterProfiler")
BiocManager::install("org.Dm.eg.db")
library(clusterProfiler)
library(org.Dm.eg.db)
library(ggplot2)

# Thresholds (used earlier for DEGs)
padj_cutoff <- 0.05
lfc_cutoff <- 1


# --- Step 1: Extract DEGs ---
up_L3 <- na.omit(rownames(res_L3)[res_L3$log2FoldChange > lfc_cutoff & res_L3$padj < padj_cutoff])
down_L3 <- na.omit(rownames(res_L3)[res_L3$log2FoldChange < -lfc_cutoff & res_L3$padj < padj_cutoff])
up_WD <- na.omit(rownames(res_WD)[res_WD$log2FoldChange > lfc_cutoff & res_WD$padj < padj_cutoff])
down_WD <- na.omit(rownames(res_WD)[res_WD$log2FoldChange < -lfc_cutoff & res_WD$padj < padj_cutoff])

# --- Step 2: FBgn → Entrez ID Conversion ---
convert_to_entrez <- function(fbgn_ids, label = "") {
        res <- bitr(fbgn_ids, fromType = "FLYBASE", toType = "ENTREZID", OrgDb = org.Dm.eg.db)
        message("✅ ", label, ": ", nrow(res), " IDs mapped from ", length(fbgn_ids))
        return(res$ENTREZID)
}

ent_up_L3 <- convert_to_entrez(up_L3, "Up L3")
ent_down_L3 <- convert_to_entrez(down_L3, "Down L3")
ent_up_WD <- convert_to_entrez(up_WD, "Up WD")
ent_down_WD <- convert_to_entrez(down_WD, "Down WD")

# --- Step 3: GO Enrichment ---
run_go <- function(entrez_ids, label = "") {
        if (length(entrez_ids) == 0) return(NULL)
        ego <- enrichGO(gene = entrez_ids, OrgDb = org.Dm.eg.db, keyType = "ENTREZID",
                        ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.2)
        if (is.null(ego) || nrow(ego@result) == 0) {
                message("⚠️ No enriched terms for ", label)
                return(NULL)
        } else {
                message("🧬 ", label, ": ", nrow(ego@result), " GO terms enriched")
                return(ego)
        }
}

ego_up_L3 <- run_go(ent_up_L3, "Upregulated in L3")
ego_down_L3 <- run_go(ent_down_L3, "Downregulated in L3")
ego_up_WD <- run_go(ent_up_WD, "Upregulated in WD")
ego_down_WD <- run_go(ent_down_WD, "Downregulated in WD")

# --- Step 4: Custom Dot Plot Function (With Grid, No Gray Background) ---
plot_go_custom <- function(ego, filename, title) {
        if (!is.null(ego) && nrow(ego@result) > 0) {
                df <- as.data.frame(ego)
                df <- df[!is.na(df$geneID) & df$geneID != "", ]
                top_terms <- head(df[order(df$p.adjust), ], 20)
                
                p <- ggplot(top_terms, aes(x = Count, y = reorder(Description, Count))) +
                        geom_point(aes(size = Count, color = p.adjust)) +
                        scale_color_gradient(low = "red", high = "blue") +
                        labs(title = title, x = "Gene Count", y = "GO Term", color = "Adj. p-value") +
                        theme_minimal(base_size = 8) +
                        theme(
                                panel.background = element_rect(fill = "white", color = NA),   # white plot panel
                                plot.background = element_rect(fill = "white", color = NA),    # white outer background
                                axis.text.y = element_text(size = 7),
                                axis.text.x = element_text(size = 8),
                                plot.title = element_text(size = 9, face = "bold")
                        )
                
                ggsave(filename, plot = p, width = 7, height = 5, dpi = 300)
                message("Dot plot saved: ", filename)
        } else {
                message("Skipping: ", title)
        }
}


# --- Step 5: Save Plots ---
plot_go_custom(ego_up_L3, "GO_dotplot_up_L3.png", "GO: Upregulated in K36R (L3)")
plot_go_custom(ego_down_L3, "GO_dotplot_down_L3.png", "GO: Downregulated in K36R (L3)")
plot_go_custom(ego_up_WD, "GO_dotplot_up_WD.png", "GO: Upregulated in K36R (WD)")
plot_go_custom(ego_down_WD, "GO_dotplot_down_WD.png", "GO: Downregulated in K36R (WD)")

# --- Step 6: Save Result Tables ---
write_result <- function(ego, filename) {
        if (!is.null(ego) && nrow(ego@result) > 0) {
                write.csv(as.data.frame(ego), filename, row.names = FALSE)
                message("Saved: ", filename)
        }
}
write_result(ego_up_L3, "GO_up_L3.csv")
write_result(ego_down_L3, "GO_down_L3.csv")
write_result(ego_up_WD, "GO_up_WD.csv")
write_result(ego_down_WD, "GO_down_WD.csv")