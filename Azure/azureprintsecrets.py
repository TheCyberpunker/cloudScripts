# Script by Retr02332
# List secrets
# https://thecyberpunker.com/pentesting/pentesting-cloud-azure/

from http import client
from azure.identity import ClientSecretCredential
from azure.identity import UsernamePasswordCredential
from azure.keyvault.secrets import SecretClient

VAULT = "<VAULTNAME>" # replace <VAULT NAME>
VAULT_URL = f"https://{VAULT}.vault.azure.net/" # not change
CLIENT_ID = "82732415-reDA-CTED-3222-25d3SFc6Rfd4" # Replace <CLIENT ID>
SECRET_ID = "135p=REDACT.E:DASFjP8ny.MASDWSDnu_lt" # Replace <SECRET ID>
TENANT_ID = "<TENANTID>" # Replace <CLIENT TENTANT ID>

credential = ClientSecretCredential(
    client_id=CLIENT_ID,
    client_secret=SECRET_ID,
    tenant_id=TENANT_ID
)

client = SecretClient(vault_url=VAULT_URL, credential=credential)

secret = client.get_secret("").value

print("\nSecret: " + secret)