#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

splitparts=$1

for i in `seq 1 $splitparts`
do
$DIR/do_analyzePRF.sh $i $splitparts &
sleep 2s
done
