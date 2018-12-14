#!/bin/bash

while true
do
echo "$(qstat -u $1)"
sleep 60s
done
