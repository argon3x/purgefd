#!/bin/bash

### By: Argon3x
### Sopported: Debian Based Systems and Termux
### Version: 1.0

# Colors
green="\e[01;32m"; blue="\e[01;34m"; red="\e[01;31m"
purple="\e[01;35m"; yellow="\e[01;33m"; end="\e[00m"
box="${blue}[${green}*${blue}]${end}"

# Function CTL_C
function ctrl_c(){
	echo -e "\n${red}>>>> ${purple}Process Canceled ${red}<<<<${end}"
	tput cnorm
	exit 1
}
trap ctrl_c INT

# Help Menu
function help_menu(){
	clear
	local script_name=${0##*/}
	echo -e "${yellow}------------------------------------------------------------${end}"
	echo -e "${blue}Parameters ${green}${script_name%.*}${end}"
	echo -e "${purple} -f <path>\t${end}Purge Only Empty Files."
	echo -e "${purple} -d <path>\t${end}Purge Only Empty Directories."
	echo -e "${purple} -a <path>\t${end}Purge Alls The Empty Files and Directories."
	echo -e "${purple} -h, --help\t${end}Show The Help Menu."
	echo -e "${yellow}------------------------------------------------------------${end}"
}

# Function File Purge
function purge_files(){
	local path_dir=$1
	local empty_files=$(find ${path_dir} -type f -empty | wc -l)
	
	echo -e "${box} ${yellow}Searching Empty Files.......${end}"; sleep 1
	if [[ ${empty_files} -ne 0 ]]; then
		echo -e "${box} ${yellow}Purging ${blue}(${green}${empty_files}${blue})${yellow} Empty Files....... ${end}\c"; sleep 1
		`find ${path_dir} -type f -empty -exec rm -f {} \; 2>/dev/null`
		if [[ $? -eq 0 ]]; then
			echo -e "${green}done${end}"
		else
			echo -e "${red}failed${end}"
		fi
		echo -e "\n${green}${empty_files} ${purple}Empty Files Were Purged${end}\n"
	else
		echo -e "${purple}>>> ${red}Not Empty Files Found ${purple}<<<"
		tput cnorm
	fi
}

# Function Directories Purge
function purge_directories(){
	local path_dir=$1
	local empty_directories=$(find ${path_dir} -type d -empty | wc -l)

	echo -e "${box} ${yellow}Searching Empty Directories.......${end}"; sleep 1
	if [[ ${empty_directories} -ne 0 ]]; then
		echo -e "${box} ${yellow}Purging ${blue}(${green}${empty_directories}${blue}) ${yellow}Empty Directories....... ${end}\c"; sleep 1
		declare -i local stderr=1
		while [[ ${stderr} -ne 0 ]]; do
			`find ${path_dir} -type d -not -path ${path_dir} -empty -exec rmdir {} \; 2>/dev/null`
			if [[ $? -eq 0 ]]; then
				declare -i stderr=0
				echo -e "${green}done${end}"
				echo -e "\n${green}${empty_directories} ${purple}Empty Files Were Purged${end}\n"
			else
				declare -i stderr=$?
			fi
		done
	else
		echo -e "${purple}>>> ${red}Not Empty Files Found ${purple}<<<"
		tput cnorm
	fi
}

if [[ $# -gt 1 ]]; then
	declare -i c=0
	while getopts ":f:d:a:h:" args; do
		case $args in
			f) files=$OPTARG; let c+=1;;
			d) directory=$OPTARG; let c+=2;;
			a) alls=$OPTARG; let c+=3;;
			*) help_menu;;
		esac
	done

	tput civis
	if [[ ${c} -eq 1 ]]; then
		purge_files ${files}
	elif [[ ${c} -eq 2 ]]; then
		purge_directories ${directory}
	elif [[ ${c} -eq 3 ]]; then
		purge_files ${alls}
		sleep 1
		purge_directories ${alls}
	fi
	tput cnorm
else
	help_menu
fi
