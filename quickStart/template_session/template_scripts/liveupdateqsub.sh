#!/bin/bash

while true
do
echo "$(qstat -u $1)"
sleep 1s
done
