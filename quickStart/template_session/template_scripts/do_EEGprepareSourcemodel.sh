#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGprepareSourcemodel
# file=do_EEGprepareSourcemodel.sh
# useqsub=false
# shortLabel=EEGprSM

### Script ###

# Input Variables and Paths #
Model=FEM

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="11:59:59"
memory=31gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';conductModel='$Model';">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGprepareSourcemodel.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m



