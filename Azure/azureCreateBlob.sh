#!/bin/bash
# https://thecyberpunker.com/pentesting/pentesting-cloud-azure/
# create blob in azure

DATE_NOW=$(date -Ru | sed 's/\+0000/GMT/')
AZ_VERSION="2018-03-28"
AZ_BLOB_URL="https://testname.blob.core.windows.net"
AZ_BLOB_CONTAINER="test"
AZ_BLOB_TARGET="${AZ_BLOB_URL}/${AZ_BLOB_CONTAINER}/"
AZ_SAS_TOKEN="?sv=2020-08-04&ss=abct&srt=sco&sp=abcdefgh&se=2024-04-06T08:00:49Z&st=2022-02-22T00:00:49Z&spr=https&sig=K4a5637829fjREDacted219124test="

curl -v -X PUT -H "Content-Type: application/octet-stream" -H "x-ms-date: ${DATE_NOW}" -H "x-ms-version: ${AZ_VERSION}" -H "x-ms-blob-type: BlockBlob" --data-binary "/temp/test.log" "${AZ_BLOB_TARGET}test.log${AZ_SAS_TOKEN}"