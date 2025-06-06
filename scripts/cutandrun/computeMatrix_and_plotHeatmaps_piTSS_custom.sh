#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=12
#SBATCH --mem=180g
#SBATCH -t 12:00:00
#SBATCH -J computeMatrix_H4ac_custom
#SBATCH -o computeMatrix_H4ac_custom.out
#SBATCH -e computeMatrix_H4ac_custom.err

module load deeptools

# === BigWig directory and files ===
bigwig_dir="/work/users/s/u/sultanah/H4ac_CutnRun/allFrags_bw"
bigwigs=(
  "$bigwig_dir/Pooled_H32_H3-2K36R_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_HWT_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_H33B_H3-3BK36R_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_H33A_H3-3Adelta_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_yw_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
  "$bigwig_dir/Pooled_Set2_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
)
labels=("H3-2K36R" "HWT" "H3-3BK36R" "H3-3Adelta" "yw" "Set2")

# === Step 1: computeMatrix for all piTSS ===
echo "Running computeMatrix for all piTSS..."
computeMatrix reference-point \
  -S "${bigwigs[@]}" \
  -R piTSS_150bp_window.bed \
  --referencePoint TSS \
  -b 100 -a 1000 \
  --binSize 10 \
  --samplesLabel "${labels[@]}" \
  --numberOfProcessors 12 \
  -out piTSS_H4ac_matrix_100bp_1kb.gz

# === Step 2: computeMatrix for top 15k piTSS ===
echo "Running computeMatrix for top 15k piTSS..."
computeMatrix reference-point \
  -S "${bigwigs[@]}" \
  -R piTSS_top15000_150bp_window.bed \
  --referencePoint TSS \
  -b 100 -a 1000 \
  --binSize 10 \
  --samplesLabel "${labels[@]}" \
  --numberOfProcessors 12 \
  -out piTSS_top15k_H4ac_matrix_100bp_1kb.gz

# === Step 3: Heatmap for all piTSS ===
echo "Plotting heatmap for all piTSS..."
plotHeatmap -m piTSS_H4ac_matrix_100bp_1kb.gz \
  -out piTSS_H4ac_heatmap_100bp_1kb_RdBu.pdf \
  --colorMap RdBu_r \
  --refPointLabel piTSS \
  --regionsLabel All_piTSS \
  --samplesLabel "${labels[@]}" \
  --sortRegions descend \
  --zMin 0 --zMax 1.6 \
  --startLabel "-100 bp" \
  --endLabel "+1 kb"

# === Step 4: Heatmap for top 15k piTSS ===
echo "Plotting heatmap for top 15k piTSS..."
plotHeatmap -m piTSS_top15k_H4ac_matrix_100bp_1kb.gz \
  -out piTSS_top15k_H4ac_heatmap_100bp_1kb_RdBu.pdf \
  --colorMap RdBu_r \
  --refPointLabel piTSS \
  --regionsLabel Top15k_piTSS \
  --samplesLabel "${labels[@]}" \
  --sortRegions descend \
  --zMin 0 --zMax 1.6 \
  --startLabel "-100 bp" \
  --endLabel "+1 kb"

echo "✅ computeMatrix and heatmap generation complete!"

