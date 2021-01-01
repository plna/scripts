#!/bin/bash


if [[ $# -eq 0 ]]; then
	echo -e "\33[31m Please give a file <kxss.txt>"
	echo -e " $0 kxss.txt \33[0m"
	exit 1
fi

n=0
for i in $(cat $1);
do
    echo "$i" | kxss
    n=$((n+1))
    if ((n%250==0))
    then
        echo $n
        echo "Pausing...5s..."
        sleep 5
    fi
done

