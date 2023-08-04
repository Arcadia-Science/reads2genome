/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Check input path parameters to see if they exist
def checkPathParamList = []
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
ch_multiqc_config                     = Channel.fromPath("$projectDir/assets/nanopore_multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config              = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo                       = params.multiqc_logo  ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ): Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { INPUT_CHECK                                       } from '../subworkflows/local/input_check'
include { MAPPING                                           } from '../subworkflows/local/mapping'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { NANOPLOT                                          } from '../modules/nf-core/nanoplot/main'
include { PORECHOP_ABI                                      } from '../modules/nf-core/porechop/abi/main'
include { FLYE                                              } from '../modules/nf-core/flye/main'
include { HIFIASM                                           } from '../modules/nf-core/hifiasm/main'
include { MEDAKA                                            } from '../modules/nf-core/medaka/main'
include { BUSCO                                             } from '../modules/nf-core/busco/main'
include { QUAST                                             } from '../modules/nf-core/quast/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS                       } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { MULTIQC                                           } from '../modules/nf-core/multiqc/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow NANOPORE {
    ch_versions = Channel.empty()

    // read in samplesheet
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    ch_reads = INPUT_CHECK.out.reads

    // stats on reads
    NANOPLOT (
        ch_reads
    )
    ch_versions = ch_versions.mix(NANOPLOT.out.versions)

    // remove adapters and QC
    PORECHOP_ABI (
        ch_reads
    )
    ch_qced_reads = PORECHOP_ABI.out.reads
    ch_versions = ch_versions.mix(PORECHOP_ABI.out.versions)

    // assembly with flye
    FLYE (
        ch_qced_reads,
        "--nano-hq"
    )
    ch_versions = ch_versions.mix(FLYE.out.versions)
    ch_flye_draft_assembly = FLYE.out.fasta

    // polish assembly
    ch_medaka = ch_reads.join(ch_flye_draft_assembly)
    MEDAKA (
        ch_medaka
    )
    ch_polished_assembly = MEDAKA.out.assembly

    // quality check assembly with busco
    BUSCO (
        ch_polished_assembly,
        params.lineage,
        [],
        []
    )
    ch_versions = ch_versions.mix(BUSCO.out.versions)

    // mapping subworkflow
    MAPPING (
        ch_polished_assembly,
        ch_qced_reads
    )
    ch_versions = ch_versions.mix(MAPPING.out.versions)

    // QUAST qc on assemblies
    QUAST (
        ch_polished_assembly.map{it -> it[1]}.collect()
    )
    ch_versions = ch_versions.mix(QUAST.out.versions)

    // dump software versions
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    // multiqc reporting
    workflow_summary = WorkflowReads2Genome.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    ch_multiqc_files = ch_multiqc_files.mix(NANOPLOT.out.txt.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(QUAST.out.results.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(BUSCO.out.short_summaries_txt.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(MAPPING.out.ch_stats.collect().ifEmpty([]))

    MULTIQC(
        ch_multiqc_files.collect(),
        ch_multiqc_config.collect().ifEmpty([]),
        ch_multiqc_custom_config.collect().ifEmpty([]),
        ch_multiqc_logo.collect().ifEmpty([])
    )
    multiqc_report = MULTIQC.out.report.toList()
    ch_versions = ch_versions.mix(MULTIQC.out.versions)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if ((params.email || params.email_on_fail) && params.from_email) {
        def email_params = NfcoreTemplate.get_email_params(workflow, params, summary_params, projectDir, log, multiqc_report)

        // PSA 1: this is a mild hack, because sendMail does not work with S3 URIs.
        // First, we attempt to send our email regularly. If email_params.mqcFile is
        // a local file path (ie you're running this pipeline on an HPC or locally),
        // this will succeed. If it refers to an S3 object, this would fail.
        // When it fails, we can forgo the main body of the email (mostly pipeline metadata)
        // and try make MultiQC HTML (which already has some of the metadata), the
        // body of our email.

        // PSA 2: On Tower, using Fusion mounts could circumvent this issue.

        try {
            // Send email using Nextflow's built-in emailer:
            // https://www.nextflow.io/docs/latest/mail.html#advanced-mail
            sendMail (
                from: params.from_email,
                to: email_params.to,
                subject: email_params.subject,
                body: email_params.email_html,
                attach: email_params.mqcFile
            )
        } catch (Exception e) {
            sendMail (
                from: params.from_email,
                to: email_params.to,
                subject: email_params.subject,
                body: email_params.mqcFile.text
            )
        }
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.adaptivecard(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
