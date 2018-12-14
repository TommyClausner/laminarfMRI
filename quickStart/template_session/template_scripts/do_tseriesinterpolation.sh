#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_tseriesinterpolation
# file=do_tseriesinterpolation.sh
# useqsub=false
# shortLabel=Tsint

### Script ###

# Input Variables and Paths #
Nblocks=3
mskThr=0.01
StimSize=100

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
echo "mainpath=" "'$DIR';numblocks=$Nblocks;mask_threshold=$mskThr;size_stims_new=$StimSize;">$DIR/tmp_$nameadd.m
cat $DIR/do_tseriesinterpolation.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m


