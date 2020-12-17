#!/bin/bash


TARGET=$1

WORKING_DIR=$(pwd -P)
TOOLS_PATH=~/tools
WORDLIST_PATH=~/mylist
RESULTS_PATH="$WORKING_DIR"
NUCLEI_PATH="$RESULTS_PATH/nuclei"

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

mkdir -p $NUCLEI_PATH
echo -e "${BLUE}[*] $NUCLEI_PATH${RESET}"

runBanner(){
    name=$1
    echo -e "${RED}\n[+] Running $name...${RESET}"
}


echo -e "${GREEN}--==[ Starting Nuclei ]==--${RESET}"

# runBanner "cves"
# nuclei -l $1 -t ~/nuclei-templates/cves/ -o $NUCLEI_PATH/cves.txt -stats -silent

# runBanner "security-misconfiguration"
# nuclei -l $1 -t ~/nuclei-templates/security-misconfiguration/ -o $NUCLEI_PATH/security-misconfiguration.txt -stats -silent

runBanner "files"
nuclei -l $1 -t ~/nuclei-templates/files/ -o $NUCLEI_PATH/files.txt -stats -silent

runBanner "pannel"
nuclei -l $1 -t ~/nuclei-templates/panels/ -o $NUCLEI_PATH/panels.txt -stats -silent

# runBanner "technologies"
# nuclei -l $1 -t ~/nuclei-templates/technologies/ -o $NUCLEI_PATH/technologies.txt -stats -silent

# runBanner "tokens"
# nuclei -l $1 -t ~/nuclei-templates/tokens/ -o $NUCLEI_PATH/tokens.txt -stats -silent

runBanner "vulnerabilities"
nuclei -l $1 -t ~/nuclei-templates/vulnerabilities/ -o $NUCLEI_PATH/vulnerabilities.txt -stats -silent

runBanner "subdomain-takeover"
nuclei -l $1 -t ~/nuclei-templates/subdomain-takeover/ -o $NUCLEI_PATH/subdomain-takeover.txt -stats -silent



echo -e "${BLUE}[*] DONE! Check results at $NUCLEI_PATH${RESET}"
