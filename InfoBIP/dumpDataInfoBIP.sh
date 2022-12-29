#!/usr/bin/bash
# Script to dump data from infobip
# https://thecyberpunker.com/ 

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
	echo " "
    echo -e  ""
    echo -e  " DUMP DATA Infobip"
    echo -e  " by TheCyberpunker"
    echo " "
}

# Fetch Jwt
function get_data(){
	# Req
    infobipURL="$INFOBIP_URL"	
    [[ $infobipURL == "null" ]] && echo -e "${RED}[${RESET}${ORANGE}-${RESET}${RED}]${RESET} Error obteniendo la Url de SONAR" && exit 1
    echo -e "${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET}  url obtenida: $infobipURL"
	token_raw="$INFOBIP_TOKEN_AUTH"
    [[ $token_raw == "null" ]] && echo -e "${RED}[${RESET}${ORANGE}-${RESET}${RED}]${RESET} Error obteniendo el Token de autenticación" && exit 1
    echo -e "${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET}  token obtenido: $token_raw"
    }

function dumping_data(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Reportes de mensajes" ;	sleep 0.5 #nice
   	reportsData=$(curl -L -g -X GET "https://$infobipURL.api.infobip.com/sms/1/reports?messageId=MESSAGEIDNUMBER1234&limit=2" -H "Authorization: App $token_raw" -H "User-Agent: curl/7.74.0" -H "Accept: application/json" --silent)
    # UserLogin=$(echo $reportsData | jq '.login')
    UserLogin=$(echo $reportsData | jq '.')
    activeTokens=$(echo $reportsData | jq '.')
    # activeTokens=$(echo $reportsData | jq '.userTokens | .[].name')
    echo -e "${ORANGE}Data Reports:${RESET} ${GREEN} $UserLogin ${RESET}\n"
    echo -e "${ORANGE}Duplicate Reports: \n${RESET} ${GREEN} $activeTokens ${RESET}\n"
}

function get_balance(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Balance" ;	sleep 0.5 #nice
   	balanceData=$(curl -L -g -X GET "https://$infobipURL.api.infobip.com/account/1/balance" -H "Authorization: App $token_raw" -H "User-Agent: curl/7.74.0" -H "Accept: application/json" --silent)
    balanceINFO=$(echo $balanceData | jq '.')
    echo -e "${ORANGE}Informacion de saldo: \n${RESET} ${GREEN} $balanceINFO ${RESET}\n"
}

function get_domains(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando dominios activos" ;	sleep 0.5 #nice
   	domainData=$(curl -L -g -X GET "https://$infobipURL.api.infobip.com/email/1/domains/DOMAINNAME.com" -H "Authorization: App $token_raw" -H "User-Agent: curl/7.74.0" -H "Accept: application/json" --silent)
    domainINFO=$(echo $domainData | jq '.')
    echo -e "${ORANGE}Informacion de dominios: \n${RESET} ${GREEN} $domainINFO ${RESET}\n"
}

function get_agents(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando agentes activos" ;	sleep 0.5 #nice
   	agentsData=$(curl -L -g -X GET "https://$infobipURL.api.infobip.com/ccaas/1/agents" -H "Authorization: App $token_raw" -H "User-Agent: curl/7.74.0" -H "Accept: application/json" --silent)
    agentsINFO=$(echo $agentsData | jq '.')
    echo -e "${ORANGE}Informacion de agentes: \n${RESET} ${GREEN} $agentsINFO ${RESET}\n"
}

function get_tags(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando tags activos" ;	sleep 0.5 #nice
   	tagsData=$(curl -L -g -X GET "https://$infobipURL.api.infobip.com/ccaas/1/tags" -H "Authorization: App $token_raw" -H "User-Agent: curl/7.74.0" -H "Accept: application/json" --silent)
    tagsINFO=$(echo $tagsData | jq '.')
    echo -e "${ORANGE}Informacion de tags: \n${RESET} ${GREEN} $tagsINFO ${RESET}\n"
}

function help(){
	echo "[+] usage: $0 --infobip-url --infobip-token []"
	exit 1
}

function main(){
		banner
        get_data
		sleep 0.5
		dumping_data
        sleep 0.5
        get_balance
        sleep 0.5
        get_domains
        sleep 0.5
        get_agents
        sleep 0.5
        get_tags
        sleep 0.5
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --infobip-url)
      INFOBIP_URL=$2
      shift 2
      ;;

    --infobip-token)
      INFOBIP_TOKEN_AUTH=$2
      shift 2
      ;;

    *)
  	  help
      ;;
  esac
done

# Flujo
main