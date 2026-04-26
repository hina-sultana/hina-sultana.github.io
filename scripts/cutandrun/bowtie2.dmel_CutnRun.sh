#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --mem=240g
#SBATCH -t 05-00:00:00

module load bowtie2
for i in `ls -1 MJN03*_clean_R1_001.fastq`
do bowtie2 -x dmel_r6.32 -1 $i -2 ${i%_clean_R1_001.fastq}_clean_R2_001.fastq -S ${i%_clean_R1_001.fastq}_dmel.sam --no-unal --no-mixed --no-discordant -p8 -q --local --very-sensitive-local --phred33 -I 10 -X 700
done

