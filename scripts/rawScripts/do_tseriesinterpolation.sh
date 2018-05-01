#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

rm $DIR/tmp.m
touch $DIR/tmp.m

if [ $# -lt 1 ]
then
memuse=64gb
else
memuse=$1
fi

nameadd=$(date +"%m%d%Y%H%M%S")

echo "mainpath=" "'$DIR';numblocks=3;mask_threshold=0.5;">$DIR/tmp_$nameadd.m
cat $DIR/do_tseriesinterpolation.m>>$DIR/tmp_$nameadd.m
echo 'matlab2013a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q batch -l walltime=48:00:00,mem=$memuse

PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)

done

rm $DIR/tmp_$nameadd.m
