##Plotting PCA plots
library(ggplot2)
library(EnhancedVolcano)
library(ggrepel)

BiocManager::install("EnhancedVolcano")

##PCA Plot of All Samples
vsd <- vst(dds, blind = TRUE)

plotPCA(vsd, intgroup = "genotype")
plotPCA(vsd, intgroup = "tissue")

# Combined plot
plotPCA(vsd, intgroup = c("tissue", "genotype"))


## Using ggplot2 to plot PCA nicely
library(DESeq2)
library(ggplot2)

# Get PCA data
# Get PCA data

## Check the range for axis of PCA plot
range(pca_data$PC1)
range(pca_data$PC2)



# Transform count data for PCA
vsd <- vst(dds, blind = TRUE)

# Extract PCA data for custom plotting
pca_data <- plotPCA(vsd, intgroup = c("tissue", "genotype"), returnData = TRUE)
percentVar <- round(100 * attr(pca_data, "percentVar"))

# Create customized PCA plot with fixed axis limits
pca_plot <- ggplot(pca_data, aes(x = PC1, y = PC2, color = tissue, shape = genotype)) +
        geom_point(size = 2, alpha = 0.6) +  # smaller points and transparency
        xlab(paste0("PC1: ", percentVar[1], "% variance")) +
        ylab(paste0("PC2: ", percentVar[2], "% variance")) +
        coord_fixed() +
        scale_x_continuous(limits = c(-110, 120)) +  # custom PC1 axis limits
        scale_y_continuous(limits = c(-15, 18))      # custom PC2 axis limits

# Save the plot
ggsave("PCA_plot_custom_limits.png", plot = pca_plot, width = 7, height = 8, dpi = 300)
ggsave("PCA_plot_custom_limits.pdf", plot = pca_plot, width = 7, height = 8, dpi = 300)