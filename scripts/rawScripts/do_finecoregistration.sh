#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

rm $DIR/tmp.m
touch $DIR/tmp.m

if [ "$#" -gt 1 ]
then
	if [ $2 -eq 1 ]
	then
		rm $DIR/../2_coregistration/*.mat
		rm $DIR/../2_coregistration/*.txt 
	fi
fi

echo "mainpath=" "'$DIR';">$DIR/tmp.m
cat $DIR/initMrVista.m>>$DIR/tmp.m
echo 'matlab2017a -desktop -r "run('"'"$DIR/tmp.m"'"')"' | qsub -q interactive -l walltime=12:00:00,mem=$1

echo initiating MATLAB session for coregistration using mrVista...

PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

done

rm $DIR/tmp.m
