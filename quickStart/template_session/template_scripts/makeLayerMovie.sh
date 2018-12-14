#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=makeLayerMovie
# file=makeLayerMovie.sh
# useqsub=false
# shortLabel=Lmovie

### Script ###

# Input Variables and Paths #
OutputVarName=none

# Output Variables and Paths #
jobtype=matlab

# Qsub information #
walltime="24:00:00"
memory=32gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';">$DIR/tmp_$nameadd.m
cat $DIR/makeLayerMovie.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m


