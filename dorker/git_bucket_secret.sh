#!/bin/bash

RED="\033[31m"
RESET="\033[0m"

echo "GITHUB: FIND BUCKET SECRET"


echo -e "\n${RED}aws_access_key${RESET}"
echo "https://github.com/search?q=org%3A$1+%22list_aws_accounts%22&type=code&o=desc&s=indexed"

echo -e "\n${RED}AWS_ACCESS_KEY_ID${RESET}"
echo "https://github.com/search?q=org%3A$1+%22AWS_ACCESS_KEY_ID%22&type=Code&o=desc&s=indexed"

echo -e "\n${RED}aws_secret_key${RESET}"
echo "https://github.com/search?q=org%3A$1+%22aws_secret_key%22&type=code&o=desc&s=indexed"

echo -e "\n${RED}S3_ACCESS_KEY_ID${RESET}"
echo "https://github.com/search?q=org%3A$1+%22S3_ACCESS_KEY_ID%22&type=code&o=desc&s=indexed"

echo -e "\n${RED}S3_BUCKET${RESET}"
echo "https://github.com/search?q=org%3A$1+%22S3_BUCKET%22&type=code&o=desc&s=indexed"

echo -e "\n${RED}S3_ENDPOINT${RESET}"
echo "https://github.com/search?q=org%3A$1+%22S3_ENDPOINT%22&type=code&o=desc&s=indexed"

echo -e "\n${RED}S3_SECRET_ACCESS_KEY${RESET}"
echo "https://github.com/search?q=org%3A$1+%22S3_SECRET_ACCESS_KEY%22&type=code&o=desc&s=indexed"

echo -e "\n${RED}list_aws_accounts${RESET}"
echo "https://github.com/search?q=org%3A$1+%22list_aws_accounts%22&type=code&o=desc&s=indexed"


