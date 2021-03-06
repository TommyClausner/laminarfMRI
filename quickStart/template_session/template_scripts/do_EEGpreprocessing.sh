#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGpreprocessing
# file=do_EEGpreprocessing.sh
# useqsub=false
# shortLabel=EEGprPr

### Script ###

# Input Variables and Paths #
RejectTrials=0

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="00:59:59"
memory=15gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';RejectTrials=$RejectTrials;">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGpreprocessing.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m



