#!/usr/bin/bash
# Script to dump data from sonar
# # https://thecyberpunker.com/ 

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
	echo -e  " DUMP SONAR DATA"
    echo -e  " by Thecyberpunker"
    echo -e  " Collab by 0xl3mon"
	echo ""
}

# Fetch Jwt
function get_data(){
	# Req
    sonarURL="$SONAR_URL"	
    [[ $sonarURL == "null" ]] && echo -e "${RED}[${RESET}${ORANGE}-${RESET}${RED}]${RESET} Error obteniendo la Url de SONAR" && exit 1
    echo -e "${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET}  url obtenida: $sonarURL"
	token_raw="$SONAR_TOKEN_AUTH"
    [[ $token_raw == "null" ]] && echo -e "${RED}[${RESET}${ORANGE}-${RESET}${RED}]${RESET} Error obteniendo el Token de autenticación" && exit 1
    echo -e "${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET}  token obtenido: $token_raw"
    }

function validate_auth(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Verificando Sesion Valida" ;	sleep 0.5 #nice
   	validAUTH=$(curl -X GET "$sonarURL/api/authentication/validate" -u "$token_raw:" --silent)
    	
    for i in ${validAUTH[@]}; do
		activeAuth="$(echo -n $i | jq '.valid')"
        echo -e "${ORANGE}Autenticacion valida:${RESET} ${GREEN} $activeAuth ${RESET}\n"
    done
}

function create_event(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Creando Evento de Analisis de SOnar" ;	sleep 0.5 #nice
   	event=$(curl -X POST "$sonarURL/api/project_analyses/create_event?analysis=eventCODE1234&name=Test" -u "$token_raw:" --silent)
    createEvent="$(echo -n $event | jq '.')"
    echo -e "${ORANGE}Evento Creado:${RESET} ${GREEN} $createEvent ${RESET}\n"
}

function dumping_data(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Login Data" ;	sleep 0.5 #nice
   	userData=$(curl -X GET "$sonarURL/api/user_tokens/search" -u "$token_raw:" --silent)
    	
    for i in ${userData[@]}; do
		UserLogin=$(echo $i | jq '.login')
        activeTokens=$(echo $i | jq '.userTokens | .[].name')
        echo -e "${ORANGE}User Login:${RESET} ${GREEN} $UserLogin ${RESET}\n"
        echo -e "${ORANGE}Active Tokens: \n${RESET} ${GREEN} $activeTokens ${RESET}\n"
	done
}

function dumping_users(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Usuarios Activos" ;	sleep 0.5 #nice
   	users=$(curl -X GET "$sonarURL/api/users/search" -u "$token_raw:" --silent)
    #activeUsers="$(echo -n $users | jq '.users | .[].login')"
    #activeUsers="$(echo -n $users | jq '.users[] | {login,name}[]')"
    activeUsers="$(echo -n $users | jq 'del(.users | .[].local,.[].externalProvider,.[].avatar)')"
    echo -e "${ORANGE}Usuarios:${RESET} ${GREEN} $activeUsers ${RESET}\n"
}

function dumping_settings(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando Valores de Configuracion" ;	sleep 0.5 #nice
   	settings=$(curl -X GET "$sonarURL/api/settings/values" -u "$token_raw:" --silent)
    settingsvalues="$(echo -n $settings | jq '.settings[] | {key,value}[]')"
    echo -e "${ORANGE}Configuraciones:${RESET} ${GREEN} $settingsvalues ${RESET}\n"
}

function dumping_plugins(){
	echo -e "\n${ORANGE}[${RESET}${GREEN}+${RESET}${ORANGE}]${RESET} Listando plugins instalados" ;	sleep 0.5 #nice
   	plugins=$(curl -X GET "$sonarURL/api/plugins/installed" -u "$token_raw:" --silent)
    activePlugins="$(echo -n $plugins | jq 'del(.plugins | .[].license,.[].organizationName,.[].organizationUrl,.[].editionBundled,.[].hash,.[].sonarLintSupported,.[].updatedAt)')"
    echo -e "${ORANGE}Configuraciones:${RESET} ${GREEN} $activePlugins ${RESET}\n"
}


function help(){
	echo "[+] usage: $0 --sonar-url --sonar-token []"
	exit 1
}

function main(){
		banner
        get_data
		sleep 0.5
		validate_auth
        sleep 0.5
        create_event
        sleep 0.5
        dumping_data
        sleep 0.5
        dumping_users
        sleep 0.5
        dumping_settings
        sleep 0.5
        dumping_plugins
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sonar-url)
      SONAR_URL=$2
      shift 2
      ;;

    --sonar-token)
      SONAR_TOKEN_AUTH=$2
      shift 2
      ;;

    *)
  	  help
      ;;
  esac
done

# Flujo
main

