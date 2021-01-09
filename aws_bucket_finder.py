#!/usr/bin/python3

import os, signal
import argparse
import time
import dns.resolver
import re
import subprocess
import requests
from dns.resolver import dns

start_time = time.time()

RED="\u001b[31m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
BLUE="\u001b[34m"
CYAN="\u001b[36m"
RESET="\u001b[0m"


name_server = '8.8.8.8'
ADDITIONAL_RDCLASS = 65535


def main():
    banner = f"""{CYAN}
           __      __        __        ___ ___     ___         __   ___  __  
 /\  |  | /__`    |__) |  | /  ` |__/ |__   |     |__  | |\ | |  \ |__  |__) 
/~~\ |/\| .__/    |__) \__/ \__, |  \ |___  |     |    | | \| |__/ |___ |  \ 
                                                    {YELLOW}Coded by k1llheal                                                                       
    {RESET}"""

    print(banner)

    parser = argparse.ArgumentParser(description='Find AWS bucket from a domain or a input file contain subdomain')
    parser.add_argument('-d','--domain', help = 'Domain name of the target [ex: example.com]')
    parser.add_argument('-f','--file', help = 'Input file contain subdomain [ex: sub.txt]')
    # parser.add_argument('command', nargs="+", help='describe what a command is')

    args = parser.parse_args()
    if not any(vars(parser.parse_args()).values()):
        parser.error(f"""{RED}No arguments provided.{RESET}""")
    
    var_domain = args.domain
    var_file = args.file

    if args.domain:
        print(f"{BLUE}[+] Enumerating sub......{RESET}")
        sub_chaos = ("chaos -d {0} | httpx -silent".format(var_domain))
        sub = ("assetfinder -subs-only {0} | httpx -silent".format(var_domain))

        content = []
        result_chaos = subprocess.check_output(sub_chaos, shell=True, encoding='utf-8')
        result = subprocess.check_output(sub, shell=True, encoding='utf-8')
        for i in result.splitlines():
            content.append(i)
        for i in result_chaos.splitlines():
            content.append(i)

        content = list(dict.fromkeys(content))
        content.sort()

        for i in content:
            print(i)
        
        content = [x.strip() for x in content]
        content = [re.sub('https?://', '', x) for x in content]

        print()
        print(f"{BLUE}[+] Finding bucket......{RESET}")
        for i in content:
            print(f"{RED}http://"+i+".s3.amazonaws.com"+f"{RESET}")
            response = requests.get("http://"+i+".s3.amazonaws.com")
            print(response.text, f"{YELLOW}")

            request = dns.message.make_query(i, dns.rdatatype.ANY)
            request.flags |= dns.flags.AD
            request.find_rrset(request.additional, dns.name.root, ADDITIONAL_RDCLASS,
                       dns.rdatatype.OPT, create=True, force_unique=True)   
            response = dns.query.udp(request, name_server)

            for i in (response.answer):
                print(i)
           
            print(f"{RESET}")

    elif args.file:
        with open(var_file, 'r') as f:
            content = f.readlines()
        
        content = [x.strip() for x in content]
        content = [re.sub('https?://', '', x) for x in content]

        for i in content:
            print(f"{RED}http://"+i+".s3.amazonaws.com"+f"{RESET}")
            response = requests.get("http://"+i+".s3.amazonaws.com")
            print(response.text, f"{YELLOW}")

            request = dns.message.make_query(i, dns.rdatatype.ANY)
            request.flags |= dns.flags.AD
            request.find_rrset(request.additional, dns.name.root, ADDITIONAL_RDCLASS,
                       dns.rdatatype.OPT, create=True, force_unique=True)   
            response = dns.query.udp(request, name_server)

            for i in (response.answer):
                print(i)
           
            print(f"{RESET}")


if __name__ == "__main__":
    try:
        main()
        print("--- %s seconds ---" % (time.time() - start_time))
    except KeyboardInterrupt:
        print("--- %s seconds ---" % (time.time() - start_time))
        print(f"{RED}>>>>>> STOP.........................")
        exit(0)

