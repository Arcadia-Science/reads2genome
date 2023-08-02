#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Arcadia-Science/reads2genome
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/Arcadia-Science/reads2genome
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

WorkflowMain.initialize(workflow, params, log)
if (params.platform == 'illumina') {
    include { ILLUMINA } from './workflows/illumina'
} else if (params.platform == 'nanopore') {
    include { NANOPORE } from './workflows/nanopore'
} else if (params.platform == 'pacbio') {
    include { PACBIO } from './workflows/pacbio'
}

workflow ARCADIASCIENCE_READS2GENOME {
    if (params.platform == 'illumina') {
        ILLUMINA()
    } else if (params.platform == 'nanopore') {
        NANOPORE()
    } else if (params.platform == 'pacbio') {
        PACBIO()
    }
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
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    ARCADIASCIENCE_READS2GENOME ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
