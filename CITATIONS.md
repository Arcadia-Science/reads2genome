# Arcadia-Science/reads2genome: Citations

Below are citations of tools used in the pipeline that you should cite in your work when using this pipeline.

## Nextflow and Reporting Tools

- [nf-core](https://pubmed.ncbi.nlm.nih.gov/32055031/)

> Ewels PA, Peltzer A, Fillinger S, Patel H, Alneberg J, Wilm A, Garcia MU, Di Tommaso P, Nahnsen S. (2020). The nf-core framework for community-curated bioinformatics pipelines. [https://doi.org/10.1038/s41587-020-0439-x](https://www.nature.com/articles/s41587-020-0439-x)

- [Nextflow](https://pubmed.ncbi.nlm.nih.gov/28398311/)

> Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. (2017). [doi: 10.1038/nbt.3820](https://www.nature.com/articles/nbt.3820)

- [MultiQC](https://pubmed.ncbi.nlm.nih.gov/27312411/)
  > Ewels P, Magnusson M, Lundin S, Käller M. MultiQC: summarize analysis results for multiple tools and samples in a single report. (2016). [doi: 10.1093/bioinformatics/btw354.](https://academic.oup.com/bioinformatics/article/32/19/3047/2196507)

## Pipeline tools

Below are pipeline-specific tools, categorized by tools for either Illumina, Pacbio, or Nanopore preprocessing, and general software tools.

### Illumina Pipeline Tools

- [Fastp](https://doi.org/10.1093/bioinformatics/bty560)
  > Shifu Chen, Yanqing Zhou, Yaru Chen, Jia Gu; fastp: an ultra-fast all-in-one FASTQ preprocessor. (2018). [https://doi.org/10.1093/bioinformatics/bty560](https://doi.org/10.1093/bioinformatics/bty560)
- [SPAdes](https://currentprotocols.onlinelibrary.wiley.com/doi/abs/10.1002/cpbi.102)
  > Andrey Prjibelski,Dmitry Antipov,Dmitry Meleshko,Alla Lapidus,Anton Korobeynikov. Using SPAdes De Novo Assembler. (2020). [https://doi.org/10.1002/cpbi.102](https://currentprotocols.onlinelibrary.wiley.com/doi/abs/10.1002/cpbi.102)

### Nanopore and PacBio Pipeline Tools

- [NanoPlot](https://academic.oup.com/bioinformatics/article/34/15/2666/4934939)
  > De Coster W, D'Hert S, Schultz DT, Cruts M, Van Broeckhoven C. NanoPack: visualizing and processing long-read sequencing data. (2018). [https://doi.org/10.1093/bioinformatics/bty149](https://academic.oup.com/bioinformatics/article/34/15/2666/4934939)
- [Flye](https://www.nature.com/articles/s41587-019-0072-8)
  > Kolmogorov M, Yuan J, Lin Y, Pevzner P. Assembly of long, error-prone reads using repeat graphs. (2019). [doi:10.1038/s41587-019-0072-8](https://www.nature.com/articles/s41587-019-0072-8)

### Nanopore-Specific Tools

- [Medaka](https://github.com/nanoporetech/medaka)
  > ONT Research. (2018). [https://github.com/nanoporetech/medaka](https://github.com/nanoporetech/medaka)
- [Porechop_ABI](https://www.biorxiv.org/content/10.1101/2022.07.07.499093v1)
  > Bonenfant Q, Noe L, Touzet H. Porechop_ABI: discovering unknown adapters in ONT sequencing reads for downstream trimming. (2022). [doi:10.1101/2022.07.07.499093](https://academic.oup.com/bioinformatics/article/34/15/2666/4934939)

### General Pipeline Tools

- [QUAST](https://academic.oup.com/bioinformatics/article/29/8/1072/228832?login=false)
  > Gurevich A, Saveliev V, Vyahhi N, Tesler G. QUAST: quality assessment tool for genome assemblies. (2013). [doi:10.1093/bioinformatics/btt086](https://academic.oup.com/bioinformatics/article/29/8/1072/228832?login=false)
- [minimap2](https://academic.oup.com/bioinformatics/article/34/18/3094/4994778)
  > Li H. Minimap2: pairwise alignment for nucleotide sequences. (2018). [https://doi.org/10.1093/bioinformatics/bty191](https://academic.oup.com/bioinformatics/article/34/18/3094/4994778)
- [Samtools](https://academic.oup.com/gigascience/article/10/2/giab008/6137722?login=false)
  > Petr Danecek, James K Bonfield, Jennifer Liddle, John Marshall, Valeriu Ohan, Martin O Pollard, Andrew Whitwham, Thomas Keane, Shane A McCarthy, Robert M Davies, Heng Li. Twelve years of SAMtools and BCFtools. (2021). [https://doi.org/10.1093/gigascience/giab008](https://academic.oup.com/gigascience/article/10/2/giab008/6137722?login=false)
- [BUSCO](https://academic.oup.com/bioinformatics/article/31/19/3210/211866)
  > Simao F, Waterhouse R, Ionnidis P, Kriventseva E, Zdobnov E. BUSCO: assessing genome assembly and annotation completeness with single-copy orthologs. (2015). [doi:10.1093/bioinformatics/btv351](https://doi.org/10.1093/bioinformatics/btv351)

# Software packaging/containerization tools

- [Docker](https://dl.acm.org/doi/10.5555/2600239.2600241)

- [Singularity](https://pubmed.ncbi.nlm.nih.gov/28494014/)
  > Kurtzer GM, Sochat V, Bauer MW. Singularity: Scientific containers for mobility of compute. (2017). [https://doi.org/10.1371/journal.pone.0177459](https://doi.org/10.1371/journal.pone.0177459)
