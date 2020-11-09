#!/bin/bash
n=0
for i in $(cat $1);
do
    echo "$i" | kxss
    n=$((n+1))
    if ((n%200))
    then
        sleep 5
    fi
done
