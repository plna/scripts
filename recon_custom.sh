#!/bin/bash


TARGET=$1

WORKING_DIR=$(pwd -P)
TOOLS_PATH=~/tools
WORDLIST_PATH=~/mylist
RESULTS_PATH="$WORKING_DIR"
SUB_PATH="$RESULTS_PATH/subdomain"
IP_PATH="$RESULTS_PATH/ip"
DIR_PATH="$RESULTS_PATH/dir"
WAYBACK_PATH="$RESULTS_PATH/wayb"
GATHER_PATH="$RESULTS_PATH/js_gather"
NUCLEI="$RESULTS_PATH/nuclei"




RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

checkArgs(){
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}[+]${BLUE} Please give a domain like ${RED}\"domain.com\"\n${RESET}"
        echo -e "${RED}[+]${BLUE} $0 ${RED}<domain>${RESET}\n"
        exit 1
    fi
}


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




runBanner(){
    name=$1
    echo -e "${RED}\n[+] Running $name...${RESET}"
}


setupDir(){
    echo -e "${GREEN}--==[ Setting things up ]==--${RESET}"
    echo -e "${RED}\n[+] Creating results directories...${RESET}"
    mkdir -p $SUB_PATH $IP_PATH $WAYBACK_PATH $NUCLEI
    mkdir -p $GATHER_PATH/scriptsresponse $GATHER_PATH/endpoints $GATHER_PATH/body $GATHER_PATH/headers

    echo -e "${BLUE}[*] $TOOLS_PATH${RESET}"
    echo -e "${BLUE}[*] $WORDLIST_PATH${RESET}"
    echo -e "${BLUE}[*] $RESULTS_PATH${RESET}"
    echo -e "${BLUE}[*] $SUB_PATH${RESET}"
    echo -e "${BLUE}[*] $IP_PATH${RESET}"
    echo -e "${BLUE}[*] $WAYBACK_PATH${RESET}"
    echo -e "${BLUE}[*] $GATHER_PATH${RESET}"
    echo -e "${BLUE}[*] $NUCLEI${RESET}"
}


enumSubs(){
    echo -e "${GREEN}\n--==[ Enumerating subdomains ]==--${RESET}"
    runBanner "Amass"
    amass enum -d $TARGET -passive -o $SUB_PATH/amass.txt

    runBanner "subfinder"
    subfinder -d $TARGET -nW -o $SUB_PATH/subfinder.txt

    runBanner "findomain"
    findomain-linux -t $TARGET -o $SUB_PATH/findomain.txt

    runBanner "crt.sh"
    curl -s "https://crt.sh/?q=%.$TARGET&output=json"  | jq -r '.[].name_value' | sed 's/\*\.//g' | grep $TARGET | sort -u | anew $SUB_PATH/crtsh.txt

    echo -e "${RED}\n[+] Combining subdomains...${RESET}"
    cat $SUB_PATH/*.txt | sort | awk '{print tolower($0)}' | uniq > $SUB_PATH/final-subdomains.txt
    echo -e "${BLUE}[*] Check the list of subdomains at $SUB_PATH/final-subdomains.txt${RESET}"

    echo -e "${GREEN}\n--==[ Checking subdomain alive ]==--${RESET}"
    runBanner "httpx"
    cat $SUB_PATH/final-subdomains.txt | httpx | sort -u > $RESULTS_PATH/alive.txt

}


visualRecon(){
    echo -e "${GREEN}\n--==[ Taking screenshots ]==--${RESET}"
    runBanner "aquatone"
    cat $RESULTS_PATH/alive.txt | aquatone -chrome-path ~/chrome-linux/chrome -out $RESULTS_PATH/aquatone/
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/aquatone/aquatone_report.html${RESET}"
    
}

screenshot(){
    echo -e "${GREEN}\n--==[ Taking screenshots ]==--${RESET}"
    runBanner "webscreenshot"
    $TOOLS_PATH/webscreenshot/webscreenshot.py -i $RESULTS_PATH/alive.txt -o $RESULTS_PATH/screenshots -t 2000
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/sreenshot/aquatone_report.html${RESET}"
    
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


wayb() {
    echo -e "${GREEN}--==[ Starting WayBack URL ]==--${RESET}"
    for i in $(cat $RESULTS_PATH/alive.txt);do echo $i | waybackurls ;done | anew $WAYBACK_PATH/wb.txt
    runBanner "paramlist"
    cat $WAYBACK_PATH/wb.txt  | sort -u | unfurl --unique keys | anew $WAYBACK_PATH/param_list.txt
    runBanner "js urls"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.js(\?|$)" | sort -u > $WAYBACK_PATH/js_urls.txt
    runBanner "php urls"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.php(\?|$)" | sort -u > $WAYBACK_PATH/php_urls.txt
    runBanner "asp url"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.aspx(\?|$)" | sort -u > $WAYBACK_PATH/aspx_urls.txt
    runBanner "jsp url"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.jsp(\?|$)" | sort -u > $WAYBACK_PATH/jsp_urls.txt
    runBanner "robots"
    cat $WAYBACK_PATH/wb.txt  | grep -P "\w+\.txt(\?|$)" | sort -u > $WAYBACK_PATH/robots.txt
    runBanner "xss"
    cat $WAYBACK_PATH/wb.txt  | gf xss | sort -u | anew $WAYBACK_PATH/xss.txt
    runBanner "sqli"
    cat $WAYBACK_PATH/wb.txt  | gf sqli | sort -u | anew $WAYBACK_PATH/sqli.txt
    runBanner "redirect"
    cat $WAYBACK_PATH/wb.txt  | gf redirect | sort -u | anew $WAYBACK_PATH/redirect.txt
    runBanner "rce"
    cat $WAYBACK_PATH/wb.txt  | gf rce | sort -u | anew $WAYBACK_PATH/rce.txt
    runBanner "ssrf"
    cat $WAYBACK_PATH/wb.txt  | gf ssrf | sort -u | anew $WAYBACK_PATH/ssrf.txt
    runBanner "s3-buckets"
    cat $WAYBACK_PATH/wb.txt  | gf s3-buckets | sort -u | anew $WAYBACK_PATH/s3-buckets.txt
    # runBanner "ssti"
    # cat $WAYBACK_PATH/wb.txt  | gf ssti | sort -u | anew $WAYBACK_PATH/ssti.txt
    runBanner "lfi"
    cat $WAYBACK_PATH/wb.txt  | gf lfi | sort -u | anew $WAYBACK_PATH/lfi.txt   
}


js_find() {
    response(){
        echo -e "${GREEN}--==[ Gathering Response ]==--${RESET}"       
                for x in $(cat $RESULTS_PATH/alive.txt)
        do
                NAME=$(echo $x | awk -F/ '{print $3}')
                curl -s -X GET -H "X-Forwarded-For: evil.com" -L $x > "$GATHER_PATH/body/$NAME"
        done
        grep "evil.com" -iro >> $RESULTS_PATH/cached_poison.txt
        echo -e "${GREEN}--==[ Checking evil.com ]==--${RESET}"
    }

    jsfinder(){
        echo -e "${GREEN}--==[ Gathering JS Files ]==--${RESET}"       
        for x in $(ls "$GATHER_PATH/body")
        do
            printf "${YELLOW}\n- $x ${RESET}"
            END_POINTS=$(cat "$GATHER_PATH/body/$x" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
            for end_point in $END_POINTS
            do
                    len=$(echo $end_point | grep "http" | wc -c)
                    URL=$end_point
                    if [ $len == 0 ]
                    then
                            URL="https://$x$end_point"
                    fi
                    echo $URL | anew $GATHER_PATH/url_js.txt
            done
        done
    }
response
jsfinder
}


fuzz_endpoint(){
    echo -e "${GREEN}\n--==[ Fuzzing by ffuf ]==--${RESET}"
    for i in $(cat $RESULTS_PATH/alive.txt); do ffuf -u $i/FUZZ -w $WORDLIST_PATH/custom_words.txt -mc 200 -t 60 ;done | tee -a $DIR_PATH/ffuf_op.txt
    echo -e "${GREEN}\n--==[ Filtering fuzz ]==--${RESET}"
    cat $DIR_PATH/ffuf_op.txt | cut -d "K" -f 2 > $RESULTS_PATH/fuff_results.txt
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/fuff_results.txt${RESET}"
}

nuclei_test(){
    echo -e "${GREEN}--==[ Starting Nuclei ]==--${RESET}"
    runBanner "cves"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/cves/ -o $NUCLEI/cves.txt  -stats -silent
    runBanner "pannel"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/panels/ -o $NUCLEI/panels.txt  -stats -silent
    runBanner "security-misconfiguration"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/security-misconfiguration/ -o $NUCLEI/security-misconfiguration.txt  -stats -silent
    runBanner "technologies"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/technologies/ -o $NUCLEI/technologies.txt  -stats -silent
    runBanner "tokens"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/tokens/ -o $NUCLEI/tokens.txt  -stats -silent
    runBanner "vulnerabilities"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/vulnerabilities/ -o $NUCLEI/vulnerabilities.txt  -stats -silent
    runBanner "subdomain-takeover"
    nuclei -l $RESULTS_PATH/alive.txt -t ~/nuclei-templates/subdomain-takeover/ -o $NUCLEI/subdomain-takeover.txt  -stats -silent
    echo -e "${BLUE}[*] Check the result at $RESULTS_PATH/ ${RESET}"
}


cors_scan(){
    echo -e "${GREEN}--==[ CORS.... ]==--${RESET}"
    $TOOLS_PATH/Corsy/corsy.py -i $RESULTS_PATH/alive.txt -o $RESULTS_PATH/cors.txt
}


open_redirect(){
    echo -e "${GREEN}--==[ OPEN REDIRECT ]==--${RESET}"
    cat $WAYBACK_PATH/oredirect.txt | xargs -I @ -P 25 sh -c 'curl -Is "@" 2>&1 | grep -q "Location: http://localhost" && tee -a $RESULTS_PATH/open_redirect.txt'
    
}


# Main function
displayLogo
checkArgs $TARGET
setupDir

enumSubs
# visualRecon
# screenshot
enumIPs
cors_scan

wayb

js_find
open_redirect
nuclei_test
# fuzz_endpoint


echo -e "${GREEN}\n--==[ DONE ]==--${RESET}"
