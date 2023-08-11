# Defining Different Queue Directives on Nextflow Tower

## Background

At Arcadia, we deploy our Nextflow workflows through Nextflow Tower using our AWS Batch setup (you can read more [here]([https://doi.org/10.57844/ARCADIA-CC5J-A519)). This allows us to take advantage of AWS EC2 spot instances for cost-savings. We found that for organisms with small genomes such as bacteria and archaea, the reads2genome workflow can complete assemblies fairly quickly and not be interrupted on spot instances. However, for organisms with larger genomes which might take multiple days to assemble, we needed to reconfigure the Nextflow Tower queue directive settings so that assemblies are run via on-demand instances and not interrupted. This also applies to Medaka polishing processes when using the `--platform nanopore ` workflow as this is currently configured for using CPUs and therefore requires long processing times.

## Defining Queue Directives in Config File

To specify certain processes to run via on-demand instances and all other processes in the workflow run via spot-instances, we setup queue directives in the config file. You can find the [Nextflow Tower documentation](https://help.tower.nf/22.3/faqs/?h=queue#queues) on this as well.

Within Nextflow Tower, setup both a spot-instance compute environment and on-demand compute environment configured for running the workflow with access to the appropriate S3 buckets. For the on-demand computer environment, make sure to copy The "head queue" found in the manual config attributes of the compute environment setup.

When setting up the "Launchpad" of the workflow to add a pipeline, make your compute environment the one that has the spot instance provisioning model. This will ensure all processes by default run on spot instances.

Then in either advanced options or within the nextflow config file provided with your workflow you will specify the processes that need to be run via on-demand instances. In your config file for example:

```
# nextflow.config

process {
    withName: FLYE {
      queue: `TowerForge-ON-DEMAND-QUEUE
    }

    withName: MEDAKA {
      queue: `TowerForge-ON-DEMAND-QUEUE
    }
}
```

Then launch the workflow, and the specified processes requiring long run times such as assembly and polishing will run via on-demand instances.
