#!/usr/bin/env bash

nextflow run nf-core/rnaseq -profile unc_longleaf \
        --input H32K36R_Samples_L3_WD.csv \
        --outdir ./results/ \
        --email "sultanah@email.unc.edu" \
        --gtf dmel-all-r6.32.filtered.gtf \
        --fasta dmel-all-chromosome-r6.32.fasta \
	--multiqc_title "H32K36R_L3_WD_PolyA-RNASeq" \
        -resume \
        -bg

