# Simple API to trigger the pipeline via Tower

This folder implements a Python script that takes a URI and triggers the reads2genome pipeline on Tower for our Nanopore Chlamy assembly runs. This is meant to be a short-term solution that should help the team be self-sufficient as they iterate on their sequencing efforts. This has no authentication at the moment, which is not great.

This folder uses conda to manage software environments and installations. You can find operating system-specific instructions for installing miniconda [here](https://training.arcadiascience.com/arcadia-users-group/20221017-conda/lesson/). After installing conda and mamba, run the following command to create the run environment.

```
mamba env create --file environment.yml
mamba activate modal
```

Following this, you need to login to Modal:

```
modal token new
```

Then, test the API with:

```
modal serve api.py
```

Or, deploy the API with:

```
modal deploy api.py
```
