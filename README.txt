HW3: Snakemake workflow for human RNA-seq preprocessing
=======================================================

Data: GEO GSE52778 (SRA SRP033351), Himes et al. 2014, PLoS One 9(6):e99625.
Human airway smooth muscle cells, paired-end Illumina RNA-seq.
Samples (config/samples.tsv): SRR1039516, SRR1039517, SRR1039520, SRR1039522.
Reference: GENCODE release 48, GRCh38 primary assembly.

Repository layout
-----------------
workflow/Snakefile          all workflow rules
workflow/envs/*.yaml        conda environment for each tool group
config/config.yaml          reference paths and tool parameters
config/samples.tsv          sample sheet (sample, condition, donor)
profiles/slurm/config.yaml  Snakemake SLURM execution profile
scripts/prepare_reference.sh  downloads GENCODE genome, GTF, transcriptome
run_workflow.sh             sbatch wrapper that runs the Snakemake controller

Workflow steps
--------------
1. download_fastq      prefetch + fasterq-dump --split-3 (SRA -> paired FASTQ)
2. fastqc_raw          FastQC on raw reads
3. fastp               adapter and quality trimming (Q20, min length 30)
4. fastqc_trimmed      FastQC on trimmed reads
5. hisat2_index        HISAT2 genome index (built only if missing)
6. hisat2_align        spliced alignment, sorted and indexed BAM
7. samtools_stats      flagstat and stats
8. featurecounts       gene-level counts for all samples (results/counts/featureCounts.txt)
9. kallisto_index      kallisto transcriptome index (built only if missing)
10. kallisto_quant     transcript abundance per sample
11. gtf_to_bed         BED12 annotation for RSeQC
12. RSeQC              bam_stat, infer_experiment, read_distribution,
                       inner_distance, geneBody_coverage
13. deepTools          multiBamSummary, plotCorrelation, plotPCA, bamPEFragmentSize
14. multiqc            final report (results/multiqc/multiqc_report.html)

How to run
----------
Requirements: conda (Miniforge) and access to a SLURM cluster.

  # 1. Snakemake environment (once)
  conda create -n snakemake -c conda-forge -c bioconda snakemake snakemake-executor-plugin-slurm
  conda activate snakemake

  # 2. Reference files (once, separate bash script)
  sbatch scripts/prepare_reference.sh

  # 3. Check what will be run
  snakemake -n --profile profiles/slurm

  # 4. Run the whole workflow on SLURM
  sbatch run_workflow.sh
  #    or interactively: snakemake --profile profiles/slurm

  # Without SLURM (single machine):
  snakemake --cores 8 --software-deployment-method conda

Analysing other data
--------------------
For other paired-end human RNA-seq samples edit only config/samples.tsv
(SRA run IDs) and, if needed, config/config.yaml (e.g. strandedness).
The Snakefile does not need to be changed.

Outputs (not stored in git)
---------------------------
data/raw/        raw FASTQ
reference/       genome, annotation, indices
results/         QC, BAM, counts, kallisto, RSeQC, deepTools, MultiQC
logs/            log file of every rule
