#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH  --mem=12g
#SBATCH -t 22:00:00



module load bedtools
for i in `ls -1 *dupsRemoved_nameSorted.bam`
do bedtools bamtobed -bedpe -- "$i" | sort -k 1,1 -k 2,2n > "${i%_nameSorted.bam}.bed"
done



