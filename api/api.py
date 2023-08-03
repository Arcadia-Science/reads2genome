from datetime import datetime
from modal import Image, Secret, Stub, web_endpoint
import os
import requests

stub = Stub("simple-nanopore-api")

api_image = Image.debian_slim(python_version="3.10").run_commands(
    "pip install playwright==1.30.0",
)

api_image = Image.debian_slim().pip_install("requests==2.26.0")


@stub.function(secret=Secret.from_name("nf-tower-secrets"), image=api_image)
@web_endpoint()
def run_pipeline(uri: str, lineage: str = "chlorophyta_odb10", platform: str = "nanopore"):
    formatted_date = datetime.now().strftime("%Y-%m-%d")
    multiqc_title = f"{formatted_date} - MultiQC Report"

    data = {
        "params": {
            "from_email": os.environ["FROM_EMAIL"],
            "email": os.environ["NOTIFICATION_EMAIL"],
            "input": uri,
            "outdir": "s3://nf-hifi2genome/2023-08-03-merttest",
            "lineage": lineage,
            "multiqc_title": multiqc_title,
            "platform": platform,
        },
    }

    headers = {
        "Authorization": f"Bearer {os.environ['TOWER_ACCESS_TOKEN']}",
        "Content-Type": "application/json",
    }

    response = requests.post(os.environ["TOWER_URL"], json=data, headers=headers)
    response.raise_for_status()
    return response.json()
