#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

rm $DIR/tmp.m
touch $DIR/tmp.m

if [ $# -lt 1 ]
then
memuse=128gb
else
memuse=$1
fi

nameadd=$(date +"%m%d%Y%H%M%S")

echo "mainpath=" "'$DIR';">$DIR/tmp_$nameadd.m
cat $DIR/do_retinotopy.m>>$DIR/tmp_$nameadd.m
echo 'matlab2013a -nosplash -nodesktop -r "try;run('"'"$DIR/tmp_$nameadd.m"'"');catch;exit;end;exit;"' | qsub -q batch -l walltime=16:00:00,mem=$memuse

PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

done

rm $DIR/tmp_$nameadd.m
