#!/bin/bash

# Parent directory containing the SRR folders
OUTDIR="fastq_output"

# Updated mapping from SRR to sample name with _L3
declare -A SAMPLE_MAP
SAMPLE_MAP["SRR5366366"]="HWT_PolyA_RNAseq_L3_rep1"
SAMPLE_MAP["SRR5366367"]="HWT_PolyA_RNAseq_L3_rep2"
SAMPLE_MAP["SRR5366368"]="HWT_PolyA_RNAseq_L3_rep3"
SAMPLE_MAP["SRR5366369"]="K36R_PolyA_RNAseq_L3_rep1"
SAMPLE_MAP["SRR5366370"]="K36R_PolyA_RNAseq_L3_rep2"
SAMPLE_MAP["SRR5366371"]="K36R_PolyA_RNAseq_L3_rep3"

# Loop through each SRR folder
for SRR_DIR in "$OUTDIR"/SRR*; do
    SRR=$(basename "$SRR_DIR")
    SAMPLE_NAME=${SAMPLE_MAP[$SRR]}
    NEW_NAME="${SAMPLE_NAME}_${SRR}"

    echo "Renaming $SRR_DIR to $OUTDIR/$NEW_NAME..."

    # Rename files inside the folder
    for fq in "$SRR_DIR"/${SRR}_*.fastq.gz; do
        suffix=$(basename "$fq" | cut -d'_' -f2)
        mv "$fq" "$SRR_DIR/${NEW_NAME}_${suffix}"
    done

    # Rename the directory
    mv "$SRR_DIR" "$OUTDIR/$NEW_NAME"
done

echo " All files and directories renamed with '_L3' in sample names."

