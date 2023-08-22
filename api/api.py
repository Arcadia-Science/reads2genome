from datetime import datetime
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from modal import Image, Secret, Stub, web_endpoint
import os
from pydantic import BaseModel
import requests

# Modal settings
stub = Stub("simple-nanopore-api")
api_image = Image.debian_slim().pip_install("requests==2.26.0")

# FastAPI settings
auth_scheme = HTTPBearer()


class RunParams(BaseModel):
    input: str
    outdir: str
    lineage: str = "chlorophyta_odb10"
    platform: str = "nanopore"
    email: str = ""


def get_multiqc_title():
    formatted_date = datetime.now().strftime("%Y-%m-%d")
    return f"{formatted_date} - MultiQC Report"


@stub.function(secret=Secret.from_name("nf-tower-secrets"), image=api_image)
@web_endpoint(method="POST")
def run_pipeline(
    params: RunParams,
    token: HTTPAuthorizationCredentials = Depends(auth_scheme),
):
    if token.credentials != os.environ["AUTH_TOKEN"]:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    notification_email = params.email or os.environ.get("NOTIFICATION_EMAIL", "")

    data = {
        "params": {
            "input": params.input,
            "outdir": params.outdir,
            "lineage": params.lineage,
            "platform": params.platform,
            "from_email": os.environ["FROM_EMAIL"],
            "email": notification_email,
            "multiqc_title": get_multiqc_title(),
        },
    }

    headers = {
        "Authorization": f"Bearer {os.environ['TOWER_ACCESS_TOKEN']}",
        "Content-Type": "application/json",
    }

    response = requests.post(os.environ["TOWER_URL"], json=data, headers=headers)
    response.raise_for_status()
    return response.json()
