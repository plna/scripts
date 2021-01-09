#!/bin/bash


OPT=$1
ARG=$2

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"


echo -e ${CYAN}'
           __      __        __        ___ ___     ___         __   ___  __  
 /\  |  | /__`    |__) |  | /  ` |__/ |__   |     |__  | |\ | |  \ |__  |__) 
/~~\ |/\| .__/    |__) \__/ \__, |  \ |___  |     |    | | \| |__/ |___ |  \ 
	    						\u001b[33m Coded by k1llheal
'${RESET}


if [ $# -eq 1 ]; then
	echo -e "${RED}usage: aws_bucket_find.py [-h] [-d DOMAIN] [-f FILE]${RESET}"
	echo -e "Try '$0 --help' for more information"
	exit 1
fi

case $OPT in
	-d)
		
		curl -s "https://crt.sh/?q=%.$ARG&output=json"  | jq -r '.[].name_value' |\
		 sed 's/\*\.//g' | grep $ARG | httpx | sort -u |\
		  sed -E 's/https?\:\/\///g' | tee sub_aws.tmp
		# assetfinder -subs-only $ARG | httpx | sort -u | anew sub_aws.tmp
		# subfinder -d $ARG | httpx | sort -u | anew sub_aws.tmp

		echo -e "\n\033[34mBucket Finding...\033[0m"
		echo
		for i in $( cat sub_aws ); do curl -s "$i.s3.amazonaws.com" && echo $i |\
		 echo -e "\n\033[31m└─> http://$i.s3.amazonaws.com\033[33m" &&
		 dig "$i" any +noall +answer && echo -e "\e[0m"; done
	;;
	-f)
		for i in $( cat $ARG ); do echo $i | sed -E 's/https?\:\/\///g' |\
		xargs -I @ sh -c 'curl -s "@.s3.amazonaws.com" && echo @ |\
		 echo -e "\n\033[31m└─> http://@.s3.amazonaws.com\033[33m" &&
		 dig "@" any +noall +answer && echo "\e[0m" '; done
	;;
	*)
		echo "usage: aws_bucket_find.py [-h] [-d DOMAIN] [-f FILE]"
		echo "	-d domain  	Domain name of the target [ex: example.com]"
	    echo "	-f FILE  	Input file contain subdomain [ex: sub.txt]"
	    echo "	-h, --help            show this help message and exit"
	;;
esac