## Final script for boxplot
# Load libraries
library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)
library(ggpubr)

# === Subset plotting order (no H3_3 mutants) ===
plot_order <- c("yw", "Set2", "HWT", "H3_2_K36R")

# === Function to load and tidy summary data ===
process_summary_file <- function(filepath, plot_order) {
        df <- read.delim(filepath, header = TRUE, check.names = FALSE)
        colnames(df) <- gsub("^'+|'+$", "", colnames(df))  # strip quotes
        
        signal_df <- df[, 4:ncol(df)]
        long_df <- pivot_longer(signal_df, cols = everything(),
                                names_to = "Sample", values_to = "Signal")
        long_df$Sample <- factor(long_df$Sample, levels = plot_order)
        
        # Filter out samples not in this subset
        long_df <- long_df %>% filter(!is.na(Sample))
        
        return(long_df)
}

# === Read files and filter ===
df_all <- process_summary_file("piTSS_H4ac_RPGC_counts.txt", plot_order)
df_top15k <- process_summary_file("piTSS_top15k_H4ac_RPGC_counts.txt", plot_order)

# === Comparisons to run ===
comparisons <- list(
        c("Set2", "yw"),
        c("H3_2_K36R", "HWT")
)

# === Function to plot with p-values ===
plot_boxplot_with_log_stats <- function(df, title, filename) {
        p <- ggplot(df, aes(x = Sample, y = Signal, fill = Sample)) +
                geom_boxplot(outlier.size = 0.3, width = 0.6) +
                stat_compare_means(comparisons = comparisons, method = "wilcox.test") +
                geom_hline(yintercept = 1, linetype = "dashed", color = "gray50") +
                scale_y_continuous(trans = "log10") +
                scale_fill_brewer(palette = "Set2") +
                theme_minimal(base_size = 14) +
                labs(title = title, y = "log10(H4ac Signal)", x = NULL) +
                theme(axis.text.x = element_text(angle = 45, hjust = 1))
        
        ggsave(filename, plot = p, width = 8, height = 6)
}

# === Function to summarize medians and p-values ===
summarize_and_compare <- function(df, group1, group2) {
        subset_df <- df %>% filter(Sample %in% c(group1, group2))
        
        stats <- subset_df %>%
                group_by(Sample) %>%
                summarise(
                        Median = median(Signal),
                        Mean = mean(Signal),
                        Log10_Median = median(log10(Signal + 1e-5)),
                        n = n()
                )
        
        test <- wilcox.test(Signal ~ Sample, data = subset_df)
        cat("\n🔍 Comparison:", group1, "vs", group2, "\n")
        print(stats)
        cat("Wilcoxon p-value:", test$p.value, "\n")
}

# === Generate plots ===
plot_boxplot_with_log_stats(df_all, "H4ac Signal at All piTSS (RPGC, subset)", "boxplot_all_piTSS_H4ac_RPGC_log_subset.pdf")
plot_boxplot_with_log_stats(df_top15k, "H4ac Signal at Top 15k piTSS (RPGC, subset)", "boxplot_top15k_piTSS_H4ac_RPGC_log_subset.pdf")

# === Run summary comparisons ===

summarize_and_compare(df_all, "Set2", "yw")
summarize_and_compare(df_all, "H3_2_K36R", "HWT")