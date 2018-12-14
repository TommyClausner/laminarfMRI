#!/bin/bash
sleep 5s
PIDqsub=$1
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 60s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
