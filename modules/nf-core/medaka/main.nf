process MEDAKA {
    tag "$meta.id"
    label 'process_high'

    // add gunzip command because won't take in .gz fasta files

    conda "bioconda::medaka=1.4.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka:1.4.4--py38h130def0_0' :
        'biocontainers/medaka:1.4.4--py38h130def0_0' }"

    input:
    tuple val(meta), path(reads), path(assembly)

    output:
    tuple val(meta), path("*.fa.gz"), emit: assembly
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gunzip -c $assembly > ${prefix}_unzipped_assembly.fa
    medaka_consensus \\
        -t $task.cpus \\
        $args \\
        -i $reads \\
        -d ${prefix}_unzipped_assembly.fa \\
        -o polishing

    mv polishing/consensus.fasta ${prefix}_polished.fasta

    gzip -n ${prefix}_polished.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        medaka: \$( medaka --version 2>&1 | sed 's/medaka //g' )
    END_VERSIONS
    """
}
