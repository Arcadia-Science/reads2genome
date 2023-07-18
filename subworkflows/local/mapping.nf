// Mapping subworkflow to map reads against the assembled reference genome and get mapping stats with samtools

include { MINIMAP2_INDEX                } from '../../modules/nf-core/minimap2/index/main'
include { MINIMAP2_ALIGN                } from '../../modules/nf-core/minimap2/align/main'
include { SAMTOOLS_STATS                } from '../../modules/nf-core/samtools/stats/main'

workflow MAPPING {
    take:
    assembly
    reads

    main:
    ch_versions = Channel.empty()

    // build index
    MINIMAP2_INDEX(assembly)
    ch_versions = ch_versions.mix(MINIMAP2_INDEX.out.versions)
    ch_index = MINIMAP2_INDEX.out.index

    // match index to corresponding reads
    ch_mapping = ch_index.join(reads)

    // align reads to index
    MINIMAP2_ALIGN(ch_mapping)
    ch_align_bam = MINIMAP2_ALIGN.out.sorted_indexed_bam

    // get samtools stats
    SAMTOOLS_STATS(ch_align_bam, assembly)
    ch_stats = SAMTOOLS_STATS.out.stats
    ch_versions = ch_versions.mix(SAMTOOLS_STATS.out.versions)

    emit:
    ch_index
    ch_align_bam
    ch_stats
    versions = ch_versions
}
