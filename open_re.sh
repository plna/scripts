#!/bin/bash
n=0
for i in $(cat $1);
do
    curl -Is $1 2>&1 | grep -q "Location: $LHOST" && echo "VULN! %"
    n=$((n+1))
    if ((n%100==0))
    then
        echo $n
        echo "Pausing...5s..."
        sleep 5
    fi
done

