process SPADES {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::spades=3.15.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.5--h95f258a_1' :
        'biocontainers/spades:3.15.5--h95f258a_1' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.scaffolds.fasta.gz')    , emit: scaffolds
    tuple val(meta), path('*.contigs.fasta.gz')      , emit: contigs
    tuple val(meta), path('*.assembly.gfa.gz')    , optional:true, emit: gfa
    tuple val(meta), path('*.log')                , emit: log
    path  "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def maxmem = task.memory.toGiga()
    """
    spades.py \\
        $args \\
        --threads $task.cpus \\
        --memory $maxmem \\
        --pe1-1 ${reads[0]} \\
        --pe1-2 ${reads[1]} \\
        -o spades
    mv spades/spades.log ${prefix}.spades.log

    mv spades/scaffolds.fasta ${prefix}.spades.scaffolds.fasta
    mv spades/contigs.fasta ${prefix}.spades.contigs.fasta
    mv spades/assembly_graph_with_scaffolds.gfa ${prefix}.spades.assembly.graph.fa

    gzip "${prefix}.spades.scaffolds.fasta"
    gzip "${prefix}.spades.contigs.fasta"
    gzip "${prefix}.spades.assembly.graph.fa"

    if [ -f scaffolds.fasta ]; then
        mv scaffolds.fasta ${prefix}.scaffolds.fa
        gzip -n ${prefix}.scaffolds.fa
    fi
    if [ -f contigs.fasta ]; then
        mv contigs.fasta ${prefix}.contigs.fa
        gzip -n ${prefix}.contigs.fa
    fi
    if [ -f transcripts.fasta ]; then
        mv transcripts.fasta ${prefix}.transcripts.fa
        gzip -n ${prefix}.transcripts.fa
    fi
    if [ -f assembly_graph_with_scaffolds.gfa ]; then
        mv assembly_graph_with_scaffolds.gfa ${prefix}.assembly.gfa
        gzip -n ${prefix}.assembly.gfa
    fi

    if [ -f gene_clusters.fasta ]; then
        mv gene_clusters.fasta ${prefix}.gene_clusters.fa
        gzip -n ${prefix}.gene_clusters.fa
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spades: \$(spades.py --version 2>&1 | sed 's/^.*SPAdes genome assembler v//; s/ .*\$//')
    END_VERSIONS
    """
}
