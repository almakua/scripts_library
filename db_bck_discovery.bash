#!/bin/bash

listnum="$(sudo ls -1 /backup/db/daily/ | wc -l)"
counter=0

echo -e "{ \"data\": [ \c"
for i in $(sudo ls -1 /backup/db/daily/)
do 
    ((counter++))
    if [ "$counter" -lt "$listnum" ]
        then echo -e "{ \"{#DB_BCK}\":\"$i\" }, \c"
        else echo -e "{ \"{#DB_BCK}\":\"$i\" } \c"
    fi
done
echo -e "] }"
