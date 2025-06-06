#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=12
#SBATCH --mem=120g
#SBATCH -t 05:00:00
#SBATCH -J metaplot_batch2
#SBATCH -o metaplot_batch2.out
#SBATCH -e metaplot_batch2.err

module load deeptools

outdir="pairwise_metaplots_2"
mkdir -p "$outdir"

# === Input BigWig files ===
bw_dir="/users/s/u/sultanah/H4ac_CutnRun/Pel_Sup_noCon_Analysis/BigWig"
bw_hwt="$bw_dir/Pooled_HWT_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"
bw_k36r="$bw_dir/Pooled_H32_H3-2K36R_3LW_wing_CnR_H4ac_pellet_dm6_trim_q5_dupsRemoved_allFrags_rpgcNorm_zNorm.bw"

# === BED files ===
bed_all="piTSS_150bp_window.bed"
bed_top15k="piTSS_top15000_150bp_window.bed"

# === Compute matrices ===
computeMatrix reference-point \
  -S "$bw_hwt" "$bw_k36r" \
  -R "$bed_all" \
  --referencePoint center -a 1000 -b 1000 \
  -o "$outdir/piTSS_all_HWT_K36R_matrix.gz"

computeMatrix reference-point \
  -S "$bw_hwt" "$bw_k36r" \
  -R "$bed_top15k" \
  --referencePoint center -a 1000 -b 1000 \
  -o "$outdir/piTSS_top15k_HWT_K36R_matrix.gz"

# === Plotting ===
plotProfile \
  -m "$outdir/piTSS_all_HWT_K36R_matrix.gz" \
  --samplesLabel HWT H3_2_K36R \
  --outFileName "$outdir/piTSS_all_HWT_K36R_normal.pdf" \
  --outFileNameData "$outdir/piTSS_all_HWT_K36R_normal.tab" \
  --colors red blue \
  --refPoint center \
  --refPointLabel "piTSS" \
  --legendLocation upper-right \
  --plotHeight 4 --plotWidth 6 \
  --plotType lines \
  --yAxisLabel "H4ac signal"

plotProfile \
  -m "$outdir/piTSS_all_HWT_K36R_matrix.gz" \
  --samplesLabel HWT H3_2_K36R \
  --outFileName "$outdir/piTSS_all_HWT_K36R_log.pdf" \
  --outFileNameData "$outdir/piTSS_all_HWT_K36R_log.tab" \
  --colors red blue \
  --refPoint center \
  --refPointLabel "piTSS" \
  --legendLocation upper-right \
  --plotHeight 4 --plotWidth 6 \
  --plotType lines \
  --yAxis log2 \
  --yAxisLabel "log2(H4ac signal)"

plotProfile \
  -m "$outdir/piTSS_top15k_HWT_K36R_matrix.gz" \
  --samplesLabel HWT H3_2_K36R \
  --outFileName "$outdir/piTSS_top15k_HWT_K36R_normal.pdf" \
  --outFileNameData "$outdir/piTSS_top15k_HWT_K36R_normal.tab" \
  --colors red blue \
  --refPoint center \
  --refPointLabel "piTSS" \
  --legendLocation upper-right \
  --plotHeight 4 --plotWidth 6 \
  --plotType lines \
  --yAxisLabel "H4ac signal"

plotProfile \
  -m "$outdir/piTSS_top15k_HWT_K36R_matrix.gz" \
  --samplesLabel HWT H3_2_K36R \
  --outFileName "$outdir/piTSS_top15k_HWT_K36R_log.pdf" \
  --outFileNameData "$outdir/piTSS_top15k_HWT_K36R_log.tab" \
  --colors red blue \
  --refPoint center \
  --refPointLabel "piTSS" \
  --legendLocation upper-right \
  --plotHeight 4 --plotWidth 6 \
  --plotType lines \
  --yAxis log2 \
  --yAxisLabel "log2(H4ac signal)"

echo "✅ Batch 2 (HWT vs H3_2_K36R) computeMatrix and plots complete."

