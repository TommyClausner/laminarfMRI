#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_analyzePRF
# file=do_analyzePRF.sh
# useqsub=false
# shortLabel=anPRF

### Script ###

# Input Variables and Paths #
InputVarName=none

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="24:00:00"
memory=64gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

nameadd=$(date +"%m%d%Y%H%M%S")

echo "mainpath=" "'$DIR';parts=$2;partnum=$1;avgdata=0;">$DIR/tmp_$nameadd.m
cat $DIR/do_analyzePRF.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2013a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q matlab -l walltime=48:00:00,mem=6gb)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m
