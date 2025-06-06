#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 16
#SBATCH --mem=240g
#SBATCH -t 05-00:00:00

module load macs/2.2.9.1
for i in `ls -1 *.bam`
do macs2 callpeak -f BAMPE -c control_files/MJN03_U35-IgG_P_AGCCTCAT-AGTAGAGA_S17_L001_dmel_trim_q5_dupsRemoved_sorted_reheader.bam --broad -n PeaksNew/${i%_dm6_trim_q5_dupsRemoved_sorted.bam}_withControl_broadPeaks -t $i --nomodel --seed 123
done

