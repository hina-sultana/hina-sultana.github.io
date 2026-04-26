#!/usr/bin/env bash

module load nextflow

nextflow run nf-core/cutandrun \
	-c my_config.config \
	--input samplesheet.csv \
	--genome 'dm6' \
	--blacklist './reference/dm6-blacklist.v2.bed.gz' \
	--normalisation_mode "CPM" \
	--peakcaller 'MACS2,seacr' \
	--use_control 'false' \
	--outdir ./results/ \
	--macs2_narrow_peak 'false' \
	--macs_gsize 142573017 \
        -resume

 
        

