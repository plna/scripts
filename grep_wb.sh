#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[36m"
RESET="\e[0m"

checkArgs(){
	if [[ $# -eq 0 ]]; then
		echo -e "${BLUE}Please give a fife like ${RED}\"wb.txt\"${RESET}"
		echo -e "${BLUE}$0 ${RED}wb.txt${RESET}"
		exit 1
	fi
}

checkArgs $1

cat $1  | sort -u | unfurl --unique keys | anew paramlist.txt

cat $1  | grep -P "\w+\.js(\?|$)" | sort -u | anew js.txt

cat $1  | grep -P "\w+\.php(\?|$)" | sort -u | anew php.txt

cat $1  | grep -P "\w+\.aspx(\?|$)" | sort -u | anew aspx.txt

cat $1  | grep -P "\w+\.jsp(\?|$)" | sort -u | anew jsp.txt

cat $1  | grep -P "\w+\.txt(\?|$)" | sort -u | anew robots.txt

cat $1  | gf xss | sort -u | anew xss.txt

cat $1  | gf sqli | sort -u | anew sqli.txt

cat $1  | gf redirect | sort -u | anew redirect.txt

cat $1  | gf rce | sort -u | anew rce.txt

cat $1  | gf ssrf | sort -u | anew ssrf.txt

cat $1  | gf s3-buckets | sort -u | anew s3-buckets.txt

# cat $1  | gf ssti | sort -u | anew ssti.txt

cat $1  | gf lfi | sort -u | anew lfi.txt

