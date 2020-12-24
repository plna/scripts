#!/bin/bash


# subfinder -d $1 | httpx | sort -u | tee sub_aws
curl -s "https://crt.sh/?q=%.$1&output=json"  | jq -r '.[].name_value' | sed 's/\*\.//g' | grep $1 | httpx | sort -u | tee sub_aws

echo -e "\n\033[36mBucket Finding...\033[0m"
rm nosuchbucket.tmp
echo
for i in $( cat sub_aws ); do curl -s "$i.s3.amazonaws.com/" && echo "$i" |\
 tee -a nosuchbucket.tmp 1>/dev/null |\
  echo -e "\n\033[31m└─> $i.s3.amazonaws.com\n\033[0m" ; done

for i in $( cat nosuchbucket.tmp ); do echo -e "\n\033[31m$i\033[0m" && dig $i; done