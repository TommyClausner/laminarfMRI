#!/bin/bash

user=tomcla

PIDs=$(qstat -u $user | awk '{print $1"."$10}' | cut -d "." -f1,4 | grep .R | cut -d "." -f1)
stillRunning=1


if [[ "$#" -ne 2 ]]
then
startPID=$(echo "$PIDs" | head -1)
endPID=$(echo "$PIDs" | tail -1)
else
startPID=$1
endPID=$2
fi

timer_output=0 # in seconds
refreshrate=120 # in seconds
user=tomcla

while [[ stillRunning -eq 1 ]]
do
stillRunning=0
counter=0
PIDs=$(qstat -u $user | awk '{print $1"."$10}' | cut -d "." -f1,4 | grep .R | cut -d "." -f1)

for i in $PIDs
do
if [[ ( i -ge $startPID ) && ( i -le $endPID  )]]
then
stillRunning=1
fi
counter=$(( $counter + 1 ))
done
sleep 1s
timer_output=$(( $timer_output + 1 ))
if [[ $timer_output -gt $refreshrate ]]
then
timer_output=0
echo jobs still running": "$counter
fi
done

