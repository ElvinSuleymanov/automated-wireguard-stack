import os
import requests;
import subprocess
from fastapi import FastAPI, Security
from helpers import verify

app = FastAPI()
ip_sidecar = os.environ["IP_SIDECAR"]
port_sidecar = os.environ["PORT_SIDECAR"]
pubkey = os.environ["SERVER_PUBLIC_KEY"]

@app.get("/health")
def health_check():
    try:
        subprocess.run(["wg", "show", "wg0"], check=True, capture_output=True)
        return {"status":"ok"}
    except:
        return {"status":"wg0 is not ready"}

@app.get("/", dependencies=[Security(verify)])
def authenticate_client_script():
    requests.post(f"http://{ip_sidecar}:{port_sidecar}", {})
    return {"public_key": pubkey}