#!/bin/bash


RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

checkArgs(){
	if [[ $# -eq 0 ]]; then
		echo -e "${BLUE}Please give a range ip like ${RED}\"98.13{6..9}.{0..255}.{0..255}\"${RESET}"
		echo -e "${BLUE}$0 ${RED}98.13{6..9}.{0..255}.{0..255}${RESET}"
		exit 1
	fi
}

checkArgs $1

# Example
# 98.13{6..9}.{0..255}.{0..255}

for ipa in $1; do \
wget -t 1 -T 5 http://${ipa}/phpinfo.php; done
