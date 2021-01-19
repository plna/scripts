#!/usr/bin/python3
import os, signal
import argparse
import time
import re
import subprocess
import requests
import os
os.environ["BROWSER"] = "open"
from urllib.parse import urlparse
import re, sys, glob, html, argparse, base64, ssl
import urllib
from gzip import GzipFile

try:
    from urllib.request import Request, urlopen
except ImportError:
    from urllib2 import Request, urlopen

start_time = time.time()

RED="\u001b[31m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
BLUE="\u001b[34m"
CYAN="\u001b[36m"
RESET="\u001b[0m"



# xxx = urlparse(a)
# print(xxx.path)                    
# print(os.path.basename(xxx.path))  

def main():
    parser = argparse.ArgumentParser(description='Download javascript file - gzip, deflate')
    parser.add_argument('-u','--url', help = 'Javascript Url [ex: example.js]')
    parser.add_argument('-f','--file', help = 'Input file contain js urls [ex: js_urls.txt]')
    parser.add_argument('-o','--output', help = 'Directory(folder) to save output')

    args = parser.parse_args()
    if not any(vars(parser.parse_args()).values()):
        parser.error(f"""{RED}No arguments provided.{RESET}""")
    
    var_url = args.url
    var_file = args.file
    var_output = args.output

    if args.url:
        print(f"{BLUE}" + var_url + f"{RESET}")

        url_parse = urlparse(var_url)
        file_name = os.path.basename(url_parse.path)

        # print(file_name)
        if args.output:
            path = os.path.join(var_output, file_name)
            with open (path, 'w') as f:
                f.write(send_request(var_url))
        else:
            with open (file_name, 'w') as f:
                f.write(send_request(var_url))

    if args.file:
        with open(var_file, 'r') as f:
            content = f.readlines()

        content = [i.strip() for i in content]
        print()
        for url in content:
            print(f"{BLUE}" + url + f"{RESET}")

            url_parse = urlparse(url)
            file_name = os.path.basename(url_parse.path)

            try:
                if args.output:
                    path = os.path.join(var_output, file_name)
                    with open (path, 'w') as f:
                        f.write(send_request(url))
                else:
                    with open (file_name, 'w') as f:
                        f.write(send_request(url))
            except Exception as ex:
                print(f"{RED}")
                print(ex)
                print(f"{RESET}")
            finally:
                continue
            

def send_request(url):
    '''
    Send requests with Requests
    '''
    q = Request(url)

    q.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) \
        AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36')
    q.add_header('Accept', 'text/html,\
        application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8')
    q.add_header('Accept-Language', 'en-US,en;q=0.8')
    q.add_header('Accept-Encoding', 'gzip')
    # q.add_header('Cookie', args.cookies)

    try:
        sslcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        response = urlopen(q, context=sslcontext)
    except:
        sslcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
        response = urlopen(q, context=sslcontext)

    if response.info().get('Content-Encoding') == 'gzip':
        data = GzipFile(fileobj=readBytesCustom(response.read())).read()
    elif response.info().get('Content-Encoding') == 'deflate':
        data = response.read().read()
    else:
        data = response.read()
    # print(data)

    return data.decode('utf-8', 'replace')


if __name__ == "__main__":
    try:
        main()
        print("--- %s seconds ---" % (time.time() - start_time))
    except KeyboardInterrupt:
        print("--- %s seconds ---" % (time.time() - start_time))
        print(f"{RED}>>>>>> STOP.........................")
        exit(0)