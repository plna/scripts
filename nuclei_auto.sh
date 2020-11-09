#!/bin/bash


TARGET=$1

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

checkArgs(){
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}[+] Usage:${RESET} $0 <alive_domain>\n"
        exit 1
    fi
}


runBanner(){
    name=$1
    echo -e "${RED}\n[+] Running $name...${RESET}"
}


echo -e "${GREEN}--==[ Starting Nuclei ]==--${RESET}"
runBanner "cves"
nuclei -l $1 -silent -t ~/nuclei-templates/cves/*.yaml -o nuclei_results/cves.txt
runBanner "files"
nuclei -l $1 -silent -t ~/nuclei-templates/files/*.yaml -o nuclei_results/files.txt
runBanner "pannel"
nuclei -l $1 -silent -t ~/nuclei-templates/panels/*.yaml -o nuclei_results/panels.txt
runBanner "security-misconfiguration"
nuclei -l $1 -silent -t ~/nuclei-templates/security-misconfiguration/*.yaml -o nuclei_results/security-misconfiguration.txt
runBanner "technologies"
nuclei -l $1 -silent -t ~/nuclei-templates/technologies/*.yaml -o nuclei_results/technologies.txt
runBanner "tokens"
nuclei -l $1 -silent -t ~/nuclei-templates/tokens/*.yaml -o nuclei_results/tokens.txt
runBanner "vulnerabilities"
nuclei -l $1 -silent -t ~/nuclei-templates/vulnerabilities/*.yaml -o nuclei_results/vulnerabilities.txt
echo -e "${BLUE}[*] DONE ${RESET}"
