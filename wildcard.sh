f [[ "$(dig @1.1.1.1 A,CNAME {test321123,testingforwildcard,plsdontgimmearesult}.$domain +short | wc -l)" -gt "1" ]]; then
    echo "[!] Possible wildcard detected."
fi
