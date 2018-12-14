#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=make_PRF_overlays
# file=make_PRF_overlays.sh
# useqsub=false
# shortLabel=Ovrly

### Script ###

# Input Variables and Paths #
OutputVarName=none

# Output Variables and Paths #
jobtype=matlab

# Qsub information #
walltime="01:00:00"
memory=32gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';">$DIR/tmp_$nameadd.m
cat $DIR/make_PRF_overlays.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m


