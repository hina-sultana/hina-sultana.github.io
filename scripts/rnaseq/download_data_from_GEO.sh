#!/bin/bash

# Array of SRX accessions
SRX_LIST=(
SRX2661635
SRX2661636
SRX2661637
SRX2661638
SRX2661639
SRX2661640
)

# Make sure SRA Toolkit is installed and configured
module load sratoolkit  # or use `conda activate` if installed via conda
module load edirect

# Create output directory
mkdir -p fastq_downloads
cd fastq_downloads

# Loop through SRX accessions
for SRX in "${SRX_LIST[@]}"; do
    echo "Processing $SRX..."
    
    # Get associated SRR accession(s)
    SRR_LIST=$(esearch -db sra -query $SRX | efetch -format runinfo | cut -d',' -f1 | grep SRR)

    for SRR in $SRR_LIST; do
        echo "Downloading $SRR..."
        
        # Prefetch (download .sra file)
        prefetch $SRR

        # Convert to FASTQ (paired-end assumed; use --split-files)
        fasterq-dump $SRR --split-files

        echo "Finished downloading $SRR"
    done
done

