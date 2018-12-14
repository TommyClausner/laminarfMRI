#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGbeamformer
# file=do_EEGbeamformer.sh
# useqsub=false
# shortLabel=EEGBeam

### Script ###

# Input Variables and Paths #
Model=FEM

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="48:00:00"
memory=31gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

if [ "$#" -ne 3 ]
then
blocks="[1,2,3,4]"
filt="[1,2]"
roi="[1,2]"
else
blocks=$1
filt=$2
roi=$3
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "start beamformer for block $blocks, filter $filt, ROI $roi"
echo "mainpath=" "'$DIR';headmodelType='$Model';BlockSel=$blocks;FiltSel=$filt;ROISel=$roi;">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGbeamformer.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m



