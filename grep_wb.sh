#!/bin/bash

cat wb.txt  | sort -u | unfurl --unique keys | anew paramlist.txt

cat wb.txt  | grep -P "\w+\.js(\?|$)" | sort -u | anew jsurls.txt

cat wb.txt  | grep -P "\w+\.php(\?|$)" | sort -u | anew phpurls.txt

cat wb.txt  | grep -P "\w+\.aspx(\?|$)" | sort -u | anew aspxurls.txt

cat wb.txt  | grep -P "\w+\.jsp(\?|$)" | sort -u | anew jspurls.txt

cat wb.txt  | grep -P "\w+\.txt(\?|$)" | sort -u | anew robots.txt

cat wb.txt  | gf xss | sort -u | anew kxss.txt

cat wb.txt  | gf sqli | sort -u | anew sqli.txt

# cat wb.txt  | gf redirect | sort -u | anew redirect.txt

# cat wb.txt  | gf lfi | sort -u | anew lfi.txt

# cat wb.txt  | gf lfi | sort -u | qsreplace FUZZ  | anew lfi_fuzz.txt