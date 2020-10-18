#!/bin/bash

VERSION="1.3"

TARGET=$1

WORKING_DIR=~/recon
TOOLS_PATH=~/tools
WORDLIST_PATH=~/mylist
RESULTS_PATH="$WORKING_DIR/$TARGET"
SUB_PATH="$RESULTS_PATH/subdomain"
CORS_PATH="$RESULTS_PATH/cors"
IP_PATH="$RESULTS_PATH/ip"
PSCAN_PATH="$RESULTS_PATH/portscan"
NUCLEI_PATH="$RESULTS_PATH/nuclei"
DIR_PATH="$RESULTS_PATH/dir"
WAYBACK_PATH="$RESULTS_PATH/wayb"
GATHER_PATH="$RESULTS_PATH/js_gather"

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

displayLogo(){
echo -e "${YELLOW}
██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝  
${RED}Custom${RESET} by ${YELLOW}@k1llheal${RESET}
"
}


checkArgs(){
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}[+] Usage:${RESET} $0 <domain>\n"
        exit 1
    fi
}


runBanner(){
    name=$1
    echo -e "${RED}\n[+] Running $name...${RESET}"
}


setupDir(){
    echo -e "${GREEN}--==[ Setting things up ]==--${RESET}"
    echo -e "${RED}\n[+] Creating results directories...${RESET}"
    # rm -rf $RESULTS_PATH
    mkdir -p $SUB_PATH $IP_PATH $PSCAN_PATH $NUCLEI_PATH $WAYBACK_PATH $DIR_PATH
    mkdir -p $GATHER_PATH/scripts $GATHER_PATH/scriptsresponse $GATHER_PATH/endpoints $GATHER_PATH/responsebody $GATHER_PATH/headers
    echo -e "${BLUE}[*] $RESULTS_PATH${RESET}"
    echo -e "${BLUE}[*] $TOOLS_PATH${RESET}"
    echo -e "${BLUE}[*] $SUB_PATH${RESET}"
    echo -e "${BLUE}[*] $CORS_PATH${RESET}"
    echo -e "${BLUE}[*] $IP_PATH${RESET}"
    echo -e "${BLUE}[*] $PSCAN_PATH${RESET}"
    echo -e "${BLUE}[*] $NUCLEI_PATH${RESET}"
    echo -e "${BLUE}[*] $WAYBACK_PATH${RESET}"
    echo -e "${BLUE}[*] $DIR_PATH${RESET}"
}


enumSubs(){
    echo -e "${GREEN}\n--==[ Enumerating subdomains ]==--${RESET}"
    runBanner "Amass"
    amass enum -d $TARGET -o $SUB_PATH/amass.txt

    runBanner "subfinder"
    subfinder -d $TARGET -t 50 -nW -o $SUB_PATH/subfinder.txt

    echo -e "${RED}\n[+] Combining subdomains...${RESET}"
    cat $SUB_PATH/*.txt | sort | awk '{print tolower($0)}' | uniq > $SUB_PATH/final-subdomains.txt
    echo -e "${BLUE}[*] Check the list of subdomains at $SUB_PATH/final-subdomains.txt${RESET}"

    echo -e "${GREEN}\n--==[ Checking for subdomain takeovers ]==--${RESET}"
    runBanner "subjack"
    subjack -a -ssl -t 50 -v -c ~/tools/subjack/fingerprints.json -w $SUB_PATH/final-subdomains.txt -o $SUB_PATH/final-takeover.tmp
    cat $SUB_PATH/final-takeover.tmp | grep -v "Not Vulnerable" > $SUB_PATH/final-takeover.txt

    echo -e "${BLUE}[*] Check subjack's result at $SUB_PATH/final-takeover.txt${RESET}"
    cat $SUB_PATH/final-subdomains.txt | httpx | anew $RESULTS_PATH/alive.txt
}


corsScan(){
    echo -e "${GREEN}\n--==[ Checking CORS configuration ]==--${RESET}"
    runBanner "Corsy"
    python3 $TOOLS_PATH/Corsy/corsy.py -i $RESULTS_PATH/alive.txt -t 50 | tee -a $RESULTS_PATH/corsy_op.txt
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/final-cors.txt${RESET}"
}


enumIPs(){
    echo -e "${GREEN}\n--==[ Resolving IP addresses ]==--${RESET}"
    runBanner "massdns"
    massdns -r $TOOLS_PATH/massdns/lists/resolvers.txt -q -t A -o S -w $IP_PATH/massdns.raw $SUB_PATH/final-subdomains.txt
    cat $IP_PATH/massdns.raw | grep -e ' A ' |  cut -d 'A' -f 2 | tr -d ' ' > $IP_PATH/massdns.txt
    cat $IP_PATH/*.txt | sort -V | uniq > $IP_PATH/final-ips.txt
    echo -e "${BLUE}[*] Check the list of IP addresses at $IP_PATH/final-ips.txt${RESET}"
}


portScan(){
    echo -e "${GREEN}\n--==[ Port-scanning targets ]==--${RESET}"
    runBanner "masscan"
    echo "anhqwe123" | sudo -S masscan -p 1-65535 --rate 10000 --wait 0 --open -iL $IP_PATH/final-ips.txt -oX $PSCAN_PATH/masscan.xml
    runBanner "xsltproc"
    xsltproc -o $PSCAN_PATH/final-masscan.html $TOOLS_PATH/nmap-bootstrap-xsl/nmap-bootstrap.xsl $PSCAN_PATH/masscan.xml
    open_ports=$(cat $PSCAN_PATH/masscan.xml | grep portid | cut -d "\"" -f 10 | sort -n | uniq | paste -sd,)
    echo -e "${BLUE}[*] Masscan Done! View the HTML report at $PSCAN_PATH/final-masscan.html${RESET}"

    runBanner "nmap"
    echo "anhqwe123" | sudo -S nmap -sVC -p $open_ports --open -v -T4 -Pn -iL $SUB_PATH/final-subdomains.txt -oX $PSCAN_PATH/nmap.xml
    xsltproc -o $PSCAN_PATH/final-nmap.html $PSCAN_PATH/nmap.xml
    echo -e "${BLUE}[*] Nmap Done! View the HTML report at $PSCAN_PATH/final-nmap.html${RESET}"
}


visualRecon(){
    echo -e "${GREEN}\n--==[ Taking screenshots ]==--${RESET}"
    runBanner "aquatone"
    cat $RESULTS_PATH/alive.txt | aquatone -chrome-path ~/chrome-linux/chrome -http-timeout 10000 -scan-timeout 300 -ports xlarge -out $RESULTS_PATH/aquatone/
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/aquatone/aquatone_report.html${RESET}"
}


fuzz_endpoint(){
    echo -e "${GREEN}\n--==[ Fuzzing by ffuf ]==--${RESET}"
    for i in $(cat $RESULTS_PATH/alive.txt); do ffuf -u $i/FUZZ -w $TOOLS_PATH/dirsearch/db/dicc.txt -mc 200 -t 60 ;done | tee -a $DIR_PATH/ffuf_op.txt
    echo -e "${GREEN}\n--==[ Filtering fuzz ]==--${RESET}"
    cat $DIR_PATH/ffuf_op.txt | cut -d "K" -f 2 > $RESULTS_PATH/fuff_results.txt
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/fuff_results.txt${RESET}"
}

nuclei_test(){
    echo -e "${GREEN}--==[ Starting Nuclei ]==--${RESET}"
    runBanner "cves"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/cves/*.yaml -c 60 -o $NUCLEI_PATH/cves.txt
    runBanner "files"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/files/*.yaml -c 60 -o $NUCLEI_PATH/files.txt
    runBanner "pannel"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/panels/*.yaml -c 60 -o $NUCLEI_PATH/panels.txt
    runBanner "security-misconfiguration"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/security-misconfiguration/*.yaml -c 60 -o $NUCLEI_PATH/security-misconfiguration.txt
    runBanner "technologies"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/technologies/*.yaml -c 60 -o $NUCLEI_PATH/technologies.txt
    runBanner "tokens"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/tokens/*.yaml -c 60 -o $NUCLEI_PATH/tokens.txt
    runBanner "vulnerabilities"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/vulnerabilities/*.yaml -c 60 -o $NUCLEI_PATH/vulnerabilities.txt
    echo -e "${BLUE}[*] Check the results at $NUCLEI_PATH/${RESET}"
}

smuggler_test(){
    echo -e "${GREEN}\n--==[ Looking for HTTP request smuggling ]==--${RESET}"
    cat $RESULTS_PATH/alive.txt | python3 $TOOLS_PATH/smuggler/smuggler.py | tee -a $RESULTS_PATH/smuggler_op.txt
}

whatweb_test() {
    echo -e "${GREEN}\n--==[ WHAT WEB ]==--${RESET}"
    whatweb -i $RESULTS_PATH/alive.txt | tee -a $RESULTS_PATH/whatweb_op.txt
}


wayb() {
    echo -e "${GREEN}--==[ Starting WayBack URL ]==--${RESET}"
    for i in $(cat $RESULTS_PATH/alive.txt);do echo $i | waybackurls ;done | anew $WAYBACK_PATH/wb.txt
    runBanner "paramlist"
    cat $WAYBACK_PATH/wb.txt  | sort -u | unfurl --unique keys | anew $WAYBACK_PATH/paramlist.txt
    runBanner "js urls"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.js(\?|$)" | sort -u | anew $WAYBACK_PATH/jsurls.txt
    runBanner "php urls"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.php(\?|$)" | sort -u  | anew $WAYBACK_PATH/phpurls.txt
    runBanner "asp url"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.aspx(\?|$)" | sort -u  | anew $WAYBACK_PATH/aspxurls.txt
    runBanner "jsp url"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.jsp(\?|$)" | sort -u | anew $WAYBACK_PATH/jspurls.txt
    runBanner "robots"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.txt(\?|$)" | sort -u  | anew $WAYBACK_PATH/robots.txt
}


jsep() {
    response(){
        echo -e "${GREEN}--==[ Gathering Response ]==--${RESET}"       
                for x in $(cat $RESULTS_PATH/alive.txt)
        do
                NAME=$(echo $x | awk -F/ '{print $3}')
                curl -X GET -H "X-Forwarded-For: evil.com" $x -I > "$GATHER_PATH/headers/$NAME" 
                curl -s -X GET -H "X-Forwarded-For: evil.com" -L $x > "$GATHER_PATH/responsebody/$NAME"
        done
    }

    jsfinder(){
        echo -e "${GREEN}--==[ Gathering JS Files ]==--${RESET}"       
        for x in $(ls "$GATHER_PATH/responsebody")
        do
            printf "${GREEN}--==[ $x ]==--${RESET}"
            END_POINTS=$(cat "$GATHER_PATH/responsebody/$x" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
            for end_point in $END_POINTS
            do
                    len=$(echo $end_point | grep "http" | wc -c)
                    mkdir "$GATHER_PATH/scriptsresponse/$x/" > /dev/null 2>&1
                    URL=$end_point
                    if [ $len == 0 ]
                    then
                            URL="https://$x$end_point"
                    fi
                    file=$(basename $end_point)
                    curl -X GET $URL -L > "$GATHER_PATH/scriptsresponse/$x/$file"
                    echo $URL >> "$GATHER_PATH/scripts/$x"
            done
        done
    }

    endpoints() {
        echo -e "${GREEN}--==[ Gathering Endpoints ]==--${RESET}"
        for domain in $(ls $GATHER_PATH/scriptsresponse)
        do
            #looping through files in each domain
            mkdir $GATHER_PATH/endpoints/$domain
            for file in $(ls $GATHER_PATH/scriptsresponse/$domain)
            do
                    cat $GATHER_PATH/scriptsresponse/$domain/$file | $TOOLS_PATH/relative-url-extractor/extract.rb >> $GATHER_PATH/endpoints/$domain/$file 
            done
        done

    }
response
jsfinder
endpoints
}

finnal_Endpoint(){
    cat $GATHER_PATH/endpoints/*/* | sort -u | anew  $RESULTS_PATH/endpoints.txt
}

# Main function
displayLogo
checkArgs $TARGET
setupDir
enumSubs
corsScan
enumIPs
portScan
visualRecon
fuzz_endpoint
nuclei_test
wayb
jsep
finnal_Endpoint



# -==[ Manual Run Recommend ]==-
# smuggler_test
# whatweb_test

echo -e "${GREEN}\n--==[ DONE ]==--${RESET}"
