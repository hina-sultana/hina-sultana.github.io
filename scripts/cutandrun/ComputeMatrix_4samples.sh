#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=12
#SBATCH --mem=180g
#SBATCH -t 12:00:00
#SBATCH -J computeMatrix_H4ac_4samples
#SBATCH -o computeMatrix_H4ac_4samples.out
#SBATCH -e computeMatrix_H4ac_4samples.err

module load deeptools

# === BigWig directory and selected files ===
bigwig_dir="/work/users/s/u/sultanah/H4ac_CutnRun/allFrags_bw"
bigwigs=(
  "$bigwig_dir/Pooled_yw_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_Set2_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_HWT_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_H32_H3-2K36R_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
)
labels=("yw" "Set2" "HWT" "H3-2K36R")

# === Step 1: computeMatrix for all piTSS ===
echo "Running computeMatrix for all piTSS (4 samples)..."
computeMatrix reference-point \
  -S "${bigwigs[@]}" \
  -R piTSS_150bp_window.bed \
  --referencePoint TSS \
  -b 100 -a 1000 \
  --binSize 10 \
  --samplesLabel "${labels[@]}" \
  --numberOfProcessors 12 \
  -out piTSS_H4ac_matrix_100bp_1kb_4samples.gz

# === Step 2: computeMatrix for top 15k piTSS ===
echo "Running computeMatrix for top 15k piTSS (4 samples)..."
computeMatrix reference-point \
  -S "${bigwigs[@]}" \
  -R piTSS_top15000_150bp_window.bed \
  --referencePoint TSS \
  -b 100 -a 1000 \
  --binSize 10 \
  --samplesLabel "${labels[@]}" \
  --numberOfProcessors 12 \
  -out piTSS_top15k_H4ac_matrix_100bp_1kb_4samples.gz

# === Step 3: Heatmap for all piTSS ===
echo "Plotting heatmap for all piTSS (4 samples)..."
plotHeatmap -m piTSS_H4ac_matrix_100bp_1kb_4samples.gz \
  -out piTSS_H4ac_heatmap_100bp_1kb_4samples.pdf \
  --colorMap RdBu_r \
  --refPointLabel piTSS \
  --regionsLabel All_piTSS \
  --samplesLabel "${labels[@]}" \
  --sortRegions descend \
  --zMin 0 --zMax 1.6 \
  --startLabel "-100 bp" \
  --endLabel "+1 kb"

# === Step 4: Heatmap for top 15k piTSS ===
echo "Plotting heatmap for top 15k piTSS (4 samples)..."
plotHeatmap -m piTSS_top15k_H4ac_matrix_100bp_1kb_4samples.gz \
  -out piTSS_top15k_H4ac_heatmap_100bp_1kb_4samples.pdf \
  --colorMap RdBu_r \
  --refPointLabel piTSS \
  --regionsLabel Top15k_piTSS \
  --samplesLabel "${labels[@]}" \
  --sortRegions descend \
  --zMin 0 --zMax 1.6 \
  --startLabel "-100 bp" \
  --endLabel "+1 kb"

echo "✅ computeMatrix and heatmap generation for 4 samples complete!"

