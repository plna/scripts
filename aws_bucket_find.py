import os
import argparse
import time
import socket
import dns.resolver
from subprocess import Popen

start_time = time.time()


RED="\u001b[31m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
BLUE="\u001b[34m"
CYAN="\u001b[36m"
RESET="\u001b[0m"


# my_resolver = dns.resolver.Resolver()
# my_resolver.nameservers = ['8.8.8.8']
# answer=my_resolver.query("status.figma.com.s3.amazonaws.com", "CNAME")

def main():
    banner = f"""{YELLOW}

   ___ _      ______  ___           __       __    _____         __       
  / _ | | /| / / __/ / _ )__ ______/ /_____ / /_  / __(_)__  ___/ /__ ____
 / __ | |/ |/ /\ \  / _  / // / __/  '_/ -_) __/ / _// / _ \/ _  / -_) __/
/_/ |_|__/|__/___/ /____/\_,_/\__/_/\_\\\__/\__/ /_/ /_/_//_/\_,_/\__/_/   
                                                                          
    {RESET}"""

    print(banner)

    parser = argparse.ArgumentParser(description='Find AWS bucket from a domain or a input file contain subdomain')
    parser.add_argument('-d','--domain', help = 'Domain name of the target [ex: example.com]')
    parser.add_argument('-f','--file', help = 'Input file contain subdomain [ex: sub.txt]')
    # parser.add_argument('command', nargs="+", help='describe what a command is')

    args = parser.parse_args()
    if not any(vars(parser.parse_args()).values()):
        parser.error(f"""{RED}No arguments provided.{RESET}""")
    
    var1 = args.domain

    # Basic query
    # for data in answer:
    #     print(data.target)

    crtsh = """curl -s "https://crt.sh/?q=%.{}&output=json"  | jq -r '.[].name_value' |\
                sed 's/\*\.//g' | grep {} | httpx | sort -u |\
                sed -E 's/https?\:\/\///g' | tee sub_aws"""
    
    # crtsh = """ echo "{}" | httpx """

    findBucket = """for i in $( cat sub_aws ); do curl -s "$i.s3.amazonaws.com" && echo $i |\
                    echo -e "\n\033[31m└─> $i.s3.amazonaws.com\033[36m" &&
                    dig "$i.s3.amazonaws.com" && echo "\e[0m"; done"""
    
    os.system(crtsh.format(str(var1), str(var1)))
    os.system(findBucket)



    # print(crtsh.format(str(var1)))

if __name__ == "__main__":
    main()
