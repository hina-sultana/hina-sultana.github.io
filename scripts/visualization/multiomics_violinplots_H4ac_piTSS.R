#Script for violin plots
# Load required libraries
library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)
library(ggpubr)
library(scales)

# === Subset plotting order (no H3_3 mutants) ===
plot_order <- c("yw", "Set2", "HWT", "H3_2_K36R")

# === Function to load and tidy multiBigwigSummary data ===
process_summary_file <- function(filepath, plot_order) {
        df <- read.delim(filepath, header = TRUE, check.names = FALSE)
        colnames(df) <- gsub("^'+|'+$", "", colnames(df))  # strip quotes
        
        signal_df <- df[, 4:ncol(df)]
        long_df <- pivot_longer(signal_df, cols = everything(),
                                names_to = "Sample", values_to = "Signal")
        long_df$Sample <- factor(long_df$Sample, levels = plot_order)
        
        # Filter to only desired samples
        long_df <- long_df %>% filter(!is.na(Sample))
        
        return(long_df)
}

# === Read data ===
df_all <- process_summary_file("piTSS_H4ac_RPGC_counts.txt", plot_order)
df_top15k <- process_summary_file("piTSS_top15k_H4ac_RPGC_counts.txt", plot_order)

# === Comparisons of interest ===
comparisons <- list(
        c("Set2", "yw"),
        c("H3_2_K36R", "HWT")
)

# === Function to generate violin plots with log-scale and p-values ===
plot_violin_with_log_stats <- function(df, title, filename) {
        p <- ggplot(df, aes(x = Sample, y = Signal, fill = Sample)) +
                geom_violin(trim = TRUE, scale = "width", alpha = 0.8, color = NA) +
                geom_boxplot(width = 0.1, outlier.size = 0.3, alpha = 0.7, color = "black") +
                stat_compare_means(comparisons = comparisons, method = "wilcox.test") +
                geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
                scale_y_continuous(trans = pseudo_log_trans(base = 10, sigma = 1e-3)) +
                scale_fill_brewer(palette = "Set2") +
                theme_minimal(base_size = 14) +
                labs(title = title, y = "log10(H4ac Signal + 1e-3)", x = NULL) +
                theme(axis.text.x = element_text(angle = 45, hjust = 1))
        
        ggsave(filename, plot = p, width = 8, height = 6)
}

# === Generate violin plots ===
plot_violin_with_log_stats(df_all, "H4ac Signal at All piTSS (Violin, log scale)", "violin_all_piTSS_H4ac_RPGC_log_subset.pdf")
plot_violin_with_log_stats(df_top15k, "H4ac Signal at Top 15k piTSS (Violin, log scale)", "violin_top15k_piTSS_H4ac_RPGC_log_subset.pdf")

