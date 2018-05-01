#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

nameadd=$(date +"%m%d%Y%H%M%S")

echo "mainpath=" "'$DIR';transmatpath=['$1'];inv_=0;">$DIR/tmp_$nameadd.m
cat $DIR/transmats2topup.m>>$DIR/tmp_$nameadd.m
echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"')"' | qsub -q batch -l walltime=12:00:00,mem=4gb

PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

done

rm $DIR/tmp_$nameadd.m
