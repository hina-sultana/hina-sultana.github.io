#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=12
#SBATCH --mem=120g
#SBATCH -t 04:00:00
#SBATCH -J multiBigwigSummary_H4ac
#SBATCH -o multiBigwigSummary_H4ac.out
#SBATCH -e multiBigwigSummary_H4ac.err

# Load DeepTools
module load deeptools

# === Path to RPGC-only bigWig files ===
bw_dir="/work/users/s/u/sultanah/multiomics/H4ac_CutnRun_RPGC_bw"

# === Full paths to bigWig files (RPGC normalized only) ===
bw_files=(
  "$bw_dir/Pooled_H32_H3-2K36R_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm.bw"
  "$bw_dir/Pooled_HWT_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm.bw"
  "$bw_dir/Pooled_H33B_H3-3BK36R_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm.bw"
  "$bw_dir/Pooled_H33A_H3-3Adelta_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm.bw"
  "$bw_dir/Pooled_yw_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm.bw"
  "$bw_dir/Pooled_Set2_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm.bw"
)

# === Sample labels (must match order of bw_files) ===
labels=("H3_2_K36R" "HWT" "H3_3_BK36R" "H3_3_Adelta" "yw" "Set2")

# === BED files ===
bed_all="piTSS_150bp_window.bed"
bed_top15k="piTSS_top15000_150bp_window.bed"

# === Run multiBigwigSummary for all piTSS ===
echo "Running multiBigwigSummary for all piTSS..."
multiBigwigSummary BED-file \
  --bwfiles "${bw_files[@]}" \
  --BED "$bed_all" \
  --labels "${labels[@]}" \
  --outFileName piTSS_H4ac_RPGC_counts.npz \
  --outRawCounts piTSS_H4ac_RPGC_counts.txt \
  --numberOfProcessors 12

# === Run multiBigwigSummary for top 15k piTSS ===
echo "Running multiBigwigSummary for top 15k piTSS..."
multiBigwigSummary BED-file \
  --bwfiles "${bw_files[@]}" \
  --BED "$bed_top15k" \
  --labels "${labels[@]}" \
  --outFileName piTSS_top15k_H4ac_RPGC_counts.npz \
  --outRawCounts piTSS_top15k_H4ac_RPGC_counts.txt \
  --numberOfProcessors 12

echo "✅ Done! RPGC-only summary files for boxplots and violin plots created."

