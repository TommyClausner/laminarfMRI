#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_coregistration
# file=do_coregistration.sh
# useqsub=false
# shortLabel=Coreg

### Script ###

# Input Variables and Paths #
registerTo=MCTemplateThrCont.nii.gz

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="24:00:00"
memory=32gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
cp $DIR/../3_coregistration/$registerTo $DIR/../3_coregistration/old$registerTo
gunzip $DIR/../3_coregistration/$registerTo
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';regvol='`basename $registerTo .gz`'">$DIR/tmp_$nameadd.m
cat $DIR/do_coregistration.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"')"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m




