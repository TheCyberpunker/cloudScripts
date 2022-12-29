# https://thecyberpunker.com/
# check aws permissions

import boto3

session = boto3.Session(
        aws_access_key_id = 'AKIAaaexampleaaaaaaaaaa',
        aws_secret_access_key = '6aexmaple./asd1@#!kdasdasda123Y'
)


def create_secret():
    client = session.client('secretsmanager', region_name="us-east-1")
    response = client.create_secret(
        Name='DatabaseProdSecrets',
        SecretString='{"username": "test", "password": "hello-world-prod"}'
    )
    print(response)

def delete_secret():
    client = session.client('secretsmanager', region_name="us-east-1")
    response = client.delete_secret(
        SecretId='DatabaseProdSecrets',
        ForceDeleteWithoutRecovery=True
    )
    print(response)

print("se crea el secret")
create_secret()
print("se borra el secret")
delete_secret()