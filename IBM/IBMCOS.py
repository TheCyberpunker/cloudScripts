import os
import datetime
import hashlib
import hmac
import requests
import sys
import urllib3


# https://thecyberpunker.com/ 
# Test IBM Cos credentials

###### burpsuite part
proxy = '127.0.0.1:8080'
os.environ['http_proxy'] = proxy
os.environ['HTTP_PROXY'] = proxy
os.environ['https_proxy'] = proxy
os.environ['HTTPS_PROXY'] = proxy
os.environ['REQUESTS_CA_BUNDLE'] = "/home/path/certificate.pem"
###### /end bursuipte part

# please don't store credentials directly in code
access_key = 'youraccesskey'
secret_key = 'yoursecretkey'

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning) # disable https warnings for burpsuite
#proxies = {'http': 'http://127.0.0.1:8080', 'https': 'http://127.0.0.1:8080'}
# request elements
http_method = 'GET'
host = 's3-api.us-geo.objectstorage.softlayer.net'
region = 'us-standard'
endpoint = 'https://s3-api.us-geo.objectstorage.softlayer.net'
bucket = ''
#bucket = '' # add a '/' before the bucket name to list buckets
object_key = ''
request_parameters = ''





# hashing and signing methods
def hash(key, msg):
    return hmac.new(key, msg.encode('utf-8'), hashlib.sha256).digest()

# region is a wildcard value that takes the place of the AWS region value
# as COS doen't use the same conventions for regions, this parameter can accept any string
def createSignatureKey(key, datestamp, region, service):

    keyDate = hash(('AWS4' + key).encode('utf-8'), datestamp)
    keyString = hash(keyDate, region)
    keyService = hash(keyString, service)
    keySigning = hash(keyService, 'aws4_request')
    return keySigning
    print(keySigning)

# assemble the standardized request
time = datetime.datetime.utcnow()
timestamp = time.strftime('%Y%m%dT%H%M%SZ')
datestamp = time.strftime('%Y%m%d')

standardized_resource = '/' + bucket + '/' + object_key
standardized_querystring = request_parameters
standardized_headers = 'host:' + host + '\n' + 'x-amz-date:' + timestamp + '\n'
signed_headers = 'host;x-amz-date'
payload_hash = hashlib.sha256(''.encode('utf-8')).hexdigest()

standardized_request = (http_method + '\n' +
                        standardized_resource + '\n' +
                        standardized_querystring + '\n' +
                        standardized_headers + '\n' +
                        signed_headers + '\n' +
                        payload_hash).encode('utf-8')


# assemble string-to-sign
hashing_algorithm = 'AWS4-HMAC-SHA256'
credential_scope = datestamp + '/' + region + '/' + 's3' + '/' + 'aws4_request'
sts = (hashing_algorithm + '\n' +
       timestamp + '\n' +
       credential_scope + '\n' +
       hashlib.sha256(standardized_request).hexdigest())
print(sts)

# generate the signature
signature_key = createSignatureKey(secret_key, datestamp, region, 's3')
signature = hmac.new(signature_key,
                     (sts).encode('utf-8'),
                     hashlib.sha256).hexdigest()


# assemble all elements into the 'authorization' header
v4auth_header = (hashing_algorithm + ' ' +
                 'Credential=' + access_key + '/' + credential_scope + ', ' +
                 'SignedHeaders=' + signed_headers + ', ' +
                 'Signature=' + signature)


# create and send the request
headers = {'x-amz-date': timestamp, 'Authorization': v4auth_header}
# the 'requests' package autmatically adds the required 'host' header
request_url = endpoint + standardized_resource + standardized_querystring

""" def create_bucket(bucket):
    print("Creating new bucket: {0}".format(bucket))
    try:
        cos.Bucket(bucket).create(
            CreateBucketConfiguration={
                "LocationConstraint":COS_BUCKET_LOCATION
            }
        )
        print("Bucket: {0} created!".format(bucket))
    except ClientError as be:
        print("CLIENT ERROR: {0}\n".format(be))
    except Exception as e:
        print("Unable to create bucket: {0}".format(e)) """


print('\nSending `%s` request to IBM COS -----------------------' % http_method)
print('Request URL = ' + request_url)
request = requests.get(request_url, headers=headers)
print('\nResponse from IBM COS ----------------------------------')
print('Response code: %d\n' % request.status_code)
print(request.text)