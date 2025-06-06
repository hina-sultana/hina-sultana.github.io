#!/bin/bash

module load bedtools


bedtools intersect -wa -wb -s \
-a sorted_merged_df_matrix_uTSS_200bpFrmDTSS_minus.bed \
-b sorted_Dominant.TSS.TES.calls.reformat.ver2.bed \
| cut -f 1-6,10-12 > intragenic_uTSS_200bpFrmDTSS_minus.bed
