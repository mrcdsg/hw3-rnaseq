#!/usr/bin/env bash
# Iškerpa vieno geno regioną iš visų BAM failų IGV peržiūrai.
# Naudojimas: bash scripts/igv_subset.sh DUSP1
set -euo pipefail
GENE="${1:-DUSP1}"
GTF="reference/gencode.v48.primary_assembly.annotation.gtf"
SAMTOOLS=$(ls .snakemake/conda/*/bin/samtools | head -1)
REGION=$(awk -v g="$GENE" '$3=="gene" && $0 ~ "gene_name \""g"\";" {print $1":"$4-2000"-"$5+2000; exit}' "$GTF")
echo "Genas $GENE, regionas $REGION"
mkdir -p igv
for bai in results/aligned/*.bam.bai; do   # tik baigti (suindeksuoti) BAM
    bam="${bai%.bai}"
    s=$(basename "$bam" .bam)
    "$SAMTOOLS" view -b -o "igv/${s}_${GENE}.bam" "$bam" "$REGION"
    "$SAMTOOLS" index "igv/${s}_${GENE}.bam"
done
echo "$REGION" > "igv/${GENE}_region.txt"
ls -lh igv/

