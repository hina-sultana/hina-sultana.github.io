#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 6
#SBATCH --mem=240g
#SBATCH -t 10:00:00
#SBATCH -J sra2fastq
#SBATCH -o slurm-%j.out

# Load the required module
module load parallel-fastq-dump/0.6.3
module load sratoolkit
module load edirect

# Set locale to avoid warnings
export LC_ALL=C
export LANG=C

# Directory containing SRR folders with .sra files
SRA_DIR="fastq_downloads"

# Output directory for fastq files
OUTDIR="fastq_output"
mkdir -p "$OUTDIR"

# Number of threads to use per file (based on SLURM -n setting)
THREADS=6

# Loop through all .sra files and convert them one by one
find "$SRA_DIR" -name "*.sra" | while read -r sra_file; do
    SRR=$(basename "$sra_file" .sra)
    echo "Processing $SRR..."

    parallel-fastq-dump \
        --sra-id "$sra_file" \
        --threads $THREADS \
        --outdir "$OUTDIR/$SRR" \
        --split-files \
        --gzip \
        --tmpdir /tmp

    echo "Finished $SRR"
done

