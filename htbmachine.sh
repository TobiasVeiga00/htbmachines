#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
	echo -e "\n\n${redColour}[!]${endColour}${turquoiseColour} Saliendo ${endColour}${yellowColour}.${endColour}${blueColour}.${endColour}${purpleColour}.${endColour}\n"
	tput cnorm && exit 1
}
# Ctrl + C
trap ctrl_c INT

# Variables Globales

main_url="https://htbmachines.github.io/bundle.js"

# Funciones de utilidad

function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
	echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios${endColour}"
	echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un ${redColour}Nombre${endColour}${grayColour} de máquina${endColour}"
	echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por ${redColour}Dirección IP${endColour}${grayColour} la de máquina${endColour}"
	echo -e "\t${purpleColour}y)${endColour} ${grayColour}Obtener ${redColour}Link${endColour} de la resolución de la máquina en ${endColour}${redColour}Youtube${endColour}"
	echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar las máquinas que posean la ${endColour}${redColour}Skill${endColour} ${grayColour}proporcionada${endColour}"
	echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar las máquinas con el ${redColour}Sistema Operativo${endColour}${grayColour} solicitado${endColour} ${redColour}(Linux, Windows)${endColour}"
	echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar las máquinas con la ${redColour}Dificultad${endColour}${grayColour} solicitada${endColour} ${redColour}(Fácil, Media, Difícil, Insane)${endColour}"
	echo -e "\t${purpleColour}o)d)${endColour} ${grayColour}Buscar las máquinas que cumplan ${redColour}Sistema Operativo${endColour} y ${redColour}Dificultad${endColour} proporcionada${endColour}"
	echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}\n"
}

function searchMachine() {
	machineName="$1"
	check_result="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^//')"
	if [ "$check_result" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de  la máquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n$check_result\n"
	else
		echo -e "\n${redColour}[!] La máquina proporcinada no existe${endColour}\n"
	fi
}

function updateFiles(){
	if [ ! -f bundle.js ]; then
		tput civis
		echo -e "\n${blueColour}[+] Descargando archivos necesarios...${endColour}\n"
		curl -s -X GET $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${blueColour}[+] Todos los archivos han sido descargados${endColour}\n"
		tput cnorm
	else
		tput civis
		echo -e "\n${blueColour}[+] Comprobando si hay actualizaciones pendientes...${endColour}\n"
		curl -s -X GET $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${blueColour}[+] No hay actualizaciones${endColour}\n"
			rm bundle_temp.js
		else
			echo -e "\n${blueColour}[+] Se actualizo el archivo bundle.js${endColour}\n"
			sleep 1
			rm bundle.js && mv bundle_temp.js bundle.js
		fi
		tput cnorm
	fi
}

function searchIP(){
	ipAddress="$1"
	check_result="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
	if [ "$check_result" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente para la IP${endColour} ${blueColour}$ipAddress${endColour} ${grayColour}es${endColour} ${blueColour}$check_result${endColour}\n"
	else
		echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
	fi
}

function getYoutubeLink(){
	machineName="$1"
	check_result="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep "youtube: " | awk 'NF{print $NF}'| tr -d '"' | tr -d ',' | sed 's/^//')"
	if [ "$check_result" ]; then
		echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El link correspondiente para la máquina${endColour} ${blueColour}$machineName${endColour} ${grayColour}es${endColour} ${blueColour}$check_result${endColour}\n"
	else
		echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
	fi
}

function getMachines(){
	difficulty="$1"
	check_result="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	if [ "$check_result" ]; then
		echo -e "\n$check_result\n"
	else
		echo -e "\n${redColour}[!] No existen máquinas con la dificultad proporcionada${endColour}\n"
	fi
}

function osMachines(){
	osystem="$1"
	check_result="$(cat bundle.js | grep "so: \"$osystem\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	if [ "$check_result" ]; then
		echo -e  "\n$check_result\n"
	else
 		echo -e "\n${redColour}[!] El Sistema Operativo proporcionado no existe${endColour}\n"
	fi
	
}

function getOsDifficulty(){
	osystem="$1"
	difficulty="$2"
	check_result="$(cat bundle.js | grep "so: \"$osystem\"" -C4 | grep "dificultad: \"$difficulty\"" -B5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	if [ "$check_result" ]; then
		echo -e "\n$check_result\n"
	else
		echo -e "$\n${redColour}[!] El Sistema Operativo y/o Dificultad proporcionada no existe${endColour}\n"
	fi
}

function machineSkill(){
	skill="$1"
	check_result="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
	if [ "$check_result" ]; then
        echo -e "\n$check_result\n"
    else
        echo -e "\n${redColour}[!] El Skill proporcionado no existe${endColour}\n"
    fi
}

# Contadores

declare -i parameter_counter=0
declare -i difficulty_counter=0
declare -i osystem_counter=0

# Agregando parametros 

while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in
		m) machineName=$OPTARG; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAddress=$OPTARG; let parameter_counter+=3;;
		y) machineName=$OPTARG; let parameter_counter+=4;;
		d) difficulty=$OPTARG; difficulty_counter=1; let parameter_counter+=5;;
		o) osystem=$OPTARG; osystem_counter=1; let parameter_counter+=6;;
		s) skill=$OPTARG; let parameter_counter+=7;;
		h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachines $difficulty
elif [ $parameter_counter -eq 6 ]; then
	osMachines $osystem
elif [ $difficulty_counter -eq 1 ] && [ $osystem_counter -eq 1 ]; then
	getOsDifficulty $osystem $difficulty
elif [ $parameter_counter -eq 7 ]; then
	machineSkill "$skill"
else
	helpPanel
 fi
