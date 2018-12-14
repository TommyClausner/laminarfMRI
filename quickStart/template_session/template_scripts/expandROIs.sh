#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=expandROIs
# file=expandROIs.sh
# useqsub=false
# shortLabel=expROIs

### Script ###

# Input Variables and Paths #
ExpandBy=4
mskThr=0.01

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="48:00:00"
memory=64gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';ExpansionFactor=$ExpandBy;maskthreshold=$mskThr;">$DIR/tmp_$nameadd.m
cat $DIR/expandROIs.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m



