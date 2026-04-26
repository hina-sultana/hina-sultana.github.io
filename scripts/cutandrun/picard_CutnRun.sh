#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16g
#SBATCH -t 10:00:00

module load picard

for i in `ls -1 *trim_q5.bam`
do
    # Define output file names
    sorted_bam="${i%.bam}_sorted.bam"
    dups_marked_bam="${i%.bam}_dupsMarked.bam"
    metrics_file="${i%.bam}_PCRduplicates.txt"

    # Sort the BAM file by coordinate
    java -Xmx8g -jar /nas/longleaf/apps/picard/2.26.11/picard-2.26.11/picard.jar SortSam \
        INPUT=$i \
        OUTPUT=$sorted_bam \
        SORT_ORDER=coordinate &&

    # Mark duplicates
    java -Xmx8g -jar /nas/longleaf/apps/picard/2.26.11/picard-2.26.11/picard.jar MarkDuplicates \
        INPUT=$sorted_bam \
        OUTPUT=$dups_marked_bam \
        METRICS_FILE=$metrics_file \
        REMOVE_DUPLICATES=false \
        ASSUME_SORTED=true
done




