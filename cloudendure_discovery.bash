#!/bin/bash

listnum="$(cat /etc/zabbix/external_scripts/cloudendure.list | wc -l)"
counter=0

echo -e "{ \"data\": [ \c"
for i in $(awk '{print $1}' /etc/zabbix/external_scripts/cloudendure.list)
do 
    ((counter++))
    if [ "$counter" -lt "$listnum" ]
        then echo -e "{ \"{#CE_HOST}\":\"$i\" }, \c"
        else echo -e "{ \"{#CE_HOST}\":\"$i\" } \c"
    fi
done
echo -e "] }"
