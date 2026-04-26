#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 2
#SBATCH  --mem=16g
#SBATCH -t 06:00:00



module load samtools
for i in `ls -1 *dupsRemoved.bam`
do samtools sort -@ 8 $i -o ${i%.bam}_sorted.bam
   samtools index ${i%.bam}_sorted.bam 	
done

