#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ $# -ge 3 ]
then
wt=$1
mem=$2
dir=$3
num=4
else
wt="4:00:00"
mem=$1
dir=$2
num=3
fi
qsub -l walltime=$wt,mem=$mem -F "$DIR ${@:$num}" $DIR/$dir
