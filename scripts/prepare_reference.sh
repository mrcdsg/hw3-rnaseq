#!/usr/bin/env bash
#SBATCH --job-name=hw3_ref
#SBATCH --partition=main
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x_%j.out
# Atsisiunčiamas GRCh38 genomas, transkriptomas ir anotaciją.
set -euo pipefail

VER="${GENCODE_VERSION:-48}"
BASE="https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${VER}"
OUT="reference"
mkdir -p "$OUT" logs

get() {
    local url="$1" name
    name=$(basename "$url" .gz)
    if [[ -s "$OUT/$name" ]]; then
        echo "Jau yra: $OUT/$name"
        return
    fi
    wget -c -O "$OUT/$name.gz" "$url"
    gunzip -f "$OUT/$name.gz"
}

get "$BASE/GRCh38.primary_assembly.genome.fa.gz"
get "$BASE/gencode.v${VER}.primary_assembly.annotation.gtf.gz"     
get "$BASE/gencode.v${VER}.transcripts.fa.gz"                       

wget -q -O "$OUT/MD5SUMS" "$BASE/MD5SUMS" || true
echo "GENCODE release ${VER}, atsisiųsta $(date -I)" > "$OUT/VERSION.txt"
ls -lh "$OUT"
