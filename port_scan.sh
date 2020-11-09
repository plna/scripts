#!/bin/bash


WORKING_DIR=$(pwd -P)
TOOLS_PATH=~/tools
WORDLIST_PATH=~/mylist
RESULTS_PATH="$WORKING_DIR"
SUB_PATH="$RESULTS_PATH/subdomain"
IP_PATH="$RESULTS_PATH/ip"

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"


runBanner(){
        name=$1
            echo -e "${RED}\n[+] Running $name...${RESET}"
            
}

massScan(){
    echo -e "${GREEN}\n--==[ Port-scanning targets ]==--${RESET}"
    runBanner "masscan"
    echo "anhqwe123" | sudo -S masscan -p 1-65535 --rate 10000 --wait 0 --open -iL $IP_PATH/final-ips.txt -oX $PSCAN_PATH/masscan.xml
    runBanner "xsltproc"
    xsltproc -o $PSCAN_PATH/final-masscan.html $TOOLS_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl $PSCAN_PATH/masscan.xml
    open_ports=$(cat $PSCAN_PATH/masscan.xml | grep portid | cut -d "\"" -f 10 | sort -n | uniq | paste -sd,)
    echo -e "${BLUE}[*] Masscan Done! View the HTML report at $PSCAN_PATH/final-masscan.html${RESET}"
}

nmapScan(){
    runBanner "nmap"
    echo "anhqwe123" | sudo -S nmap -sVC -p $open_ports --open -v -T4 -Pn -iL $SUB_PATH/alive.txt -oX $PSCAN_PATH/nmap.xml
    xsltproc -o $PSCAN_PATH/final-nmap.html $PSCAN_PATH/nmap.xml
    echo -e "${BLUE}[*] Nmap Done! View the HTML report at $PSCAN_PATH/final-nmap.html${RESET}"
}


massScan
#nmapScan
