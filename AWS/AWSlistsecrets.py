# https://thecyberpunker.com/
# list secrets aws
import boto3

session = boto3.Session(
	aws_access_key_id = 'AKIAaaexampleaaaaaaaaaa',
	aws_secret_access_key = '6aexmaple./asd1@#!kdasdasda123Y'
)

def list_secrets():
	client = session.client('secretsmanager', region_name="us-east-1")
	response = client.list_secrets()
	for key in response['SecretList']:
		print(key['Description'])
		SecretString = get_secret_value(key['ARN'])
		print(SecretString['SecretString'])

def get_secret_value(name, version=None):
	secrets_client = session.client("secretmanager", region_name="us-east-1")
	kwargs = {'SecretId' : name}
	if version is not None:
		kwargs['VersionStage'] = version
	response = secrets_client.get_secret_value(**kwargs)
	return response

list_secrets()