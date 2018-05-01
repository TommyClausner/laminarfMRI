#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

cp $DIR/../2_coregistration/$1 $DIR/../2_coregistration/old$1
gunzip $DIR/../2_coregistration/$1

nameadd=$(date +"%m%d%Y%H%M%S")

echo "mainpath=" "'$DIR';regvol='`basename $1 .gz`'">$DIR/tmp_$nameadd.m
cat $DIR/do_coregistration.m>>$DIR/tmp_$nameadd.m
echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"')"' | qsub -q batch -l walltime=12:00:00,mem=8gb

PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

done

rm $DIR/tmp_$nameadd.m
