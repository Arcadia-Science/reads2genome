# Arcadia-Science/reads2genome Output

This page describes the output files and report produced by the pipeline. The directories listed below are created in the results directory after the pipeline has finished.

## Pipeline Overview

The workflow supports reads in `.fastq` format from either Illumina, Nanopore, or Pacbio technologies. Assemblies are produced from the reads and assembly statistics summarized with `QUAST`, reads mapped back to the assembly and mapping statistics produced with `samtools stat` and lineage-specific QC statistics produced with `BUSCO`. The workflow then reports these QC stats into an HTML report produced with `MultiQC`.

### Technology-Specific Preprocessing and Assembly

Depending on the input reads and `--platform` parameter provided to the pipeline, preprocessing and assembly steps are technology-specific. Everything downstream of an assembly (that is polished for Nanopore) are identical steps and output. Regardless of platform, the preprocessing steps involve performing read QC and summarizing the quality statistics, and assembling reads into contigs. For Nanopore, the assembly is further polished with one round of Medaka.

### QUAST Assembly QC

For each assembly, QC stats are reported from `QUAST`. Due to input/output requirements by `QUAST` all genome assemblies resulting from the pipeline must be ran in a single `QUAST` process and the statistics for each assembly are in a single `report.tsv` file. This contains information such as N50, L50, number of contigs longer than a certain length, etc. Within the `QUAST` output directory, basic stats and plots are given for the assemblies.

### BUSCO QC

For each assembly, lineage specific QC stats are reported. By default the `auto` option is ran where the best fitting lineage is selected. For each assembly, a `*.batch_summary.txt` and `short_summary` file are produced. The former gives a general summary of the `BUSCO `results where the `short_summary` file gives more specifics on number of BUSCOs found, number that were searched against, and the versions of the dependencies.

### Minimap2 mapping

The pipeline maps the original reads back to the corresponding resulting assembly to facilitate downstream manual coverage checking with a program such as IGV. In the `minimap2` directory are the reference index created by `minimap2` for each assembly and the reads mapped back to the reference index in BAM format. The BAM file has been sorted and indexed.

### Samtools stats

Mapping statistics such as % of reads mapping to the assembly and alignment metrics are produced using `samtools stats` and displayed in the MultiQC report.

### Pipeline overview

The `pipeline_overview` directory provides information about how the pipeline was run.

### Custom

The `custom` directory contains the `software_versions.yml` file that gives a list of the versions of each piece of software used in the pipeline.
