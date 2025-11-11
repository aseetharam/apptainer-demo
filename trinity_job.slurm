#!/bin/bash
#SBATCH -A rcac
#SBATCH -p cpu
#SBATCH -N 1
#SBATCH -n 16
#SBATCH -t 01:00:00
#SBATCH --mem=64G
#SBATCH -J trinity_assembly
#SBATCH -o trinity_%j.out
#SBATCH -e trinity_%j.err

module --force purge

DATA=$SCRATCH/20251021_AirwayStudy_RNAseq/01_data/raw
OUTDIR=$SCRATCH/trinity_out
OVERLAY=$SCRATCH/trinity_overlay.img

apptainer exec --overlay $OVERLAY trinity.sif Trinity \
    --seqType fq \
    --max_memory 60G \
    --CPU 16 \
    --left $DATA/SRR1039508.fastq.gz \
    --output $OUTDIR