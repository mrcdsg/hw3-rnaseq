#!/usr/bin/env bash
#SBATCH --job-name=hw3_snakemake
#SBATCH --partition=main
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=2-00:00:00
#SBATCH --output=logs/snakemake_%j.out
set -euo pipefail
source ~/miniforge3/etc/profile.d/conda.sh
conda activate snakemake

# Išvalom šio darbo SLURM kintamuosius, kad jie nepersiduotų taisyklių darbams
for v in $(compgen -e | grep '^SLURM_'); do unset "$v"; done

snakemake --profile profiles/slurm "$@"
