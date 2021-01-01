#!/bin/bash


OPT=$1
ARG=$2

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"


echo -e ${YELLOW}'
           __      __        __        ___ ___     ___         __   ___  __  
 /\  |  | /__`    |__) |  | /  ` |__/ |__   |     |__  | |\ | |  \ |__  |__) 
/~~\ |/\| .__/    |__) \__/ \__, |  \ |___  |     |    | | \| |__/ |___ |  \ 

'${RESET}


if [ $# -eq 1 ]; then
	echo -e "${RED}usage: aws_bucket_find.py [-h] [-d DOMAIN] [-f FILE]${RESET}"
	echo -e "Try '$0 --help' for more information"
	exit 1
fi

case $OPT in
	-d)
		# subfinder -d $1 | httpx | sort -u | tee sub_aws
		curl -s "https://crt.sh/?q=%.$ARG&output=json"  | jq -r '.[].name_value' |\
		 sed 's/\*\.//g' | grep $ARG | httpx | sort -u |\
		  sed -E 's/https?\:\/\///g' | tee sub_aws

		echo -e "\n\033[34mBucket Finding...\033[0m"
		echo
		for i in $( cat sub_aws ); do curl -s "$i.s3.amazonaws.com" && echo $i |\
		 echo -e "\n\033[31m└─> $i.s3.amazonaws.com\033[36m" &&
		 dig "$i.s3.amazonaws.com" && echo -e "\e[0m"; done
	;;
	-f)
		for i in $( cat $ARG ); do echo $i | sed -E 's/https?\:\/\///g' |\
		xargs -I @ sh -c 'curl -s "@.s3.amazonaws.com" && echo @ |\
		 echo -e "\n\033[31m└─> @.s3.amazonaws.com\033[36m" &&
		 dig "@.s3.amazonaws.com" && echo "\e[0m" '; done
	;;
	*)
		echo "usage: aws_bucket_find.py [-h] [-d DOMAIN] [-f FILE]"
		echo "	-d domain  	Domain name of the target [ex: example.com]"
	    echo "	-f FILE  	Input file contain subdomain [ex: sub.txt]"
	    echo "	-h, --help            show this help message and exit"
	;;
esac