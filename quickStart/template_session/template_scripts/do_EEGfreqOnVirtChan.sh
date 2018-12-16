#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGfreqOnVirtChan
# file=do_EEGfreqOnVirtChan.sh
# useqsub=false
# shortLabel=EEGfreq

### Script ###

# Input Variables and Paths #
InputVarName=none

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="24:00:00"
memory=60gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

if [ "$#" -ne 3 ]
then
blocks=1
filt=1
roi=1
else
blocks=$1
filt=$2
roi=$3
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "compute virtual channels for block $blocks, filter $filt, roi $roi"
#echo "mainpath=" "'$DIR';BlockSel=$blocks;FiltSel=$filt;ROISel=$roi;">$DIR/tmp_$nameadd.m
echo "mainpath=" "'$DIR';BlockSel=$blocks;FiltSel=$filt;">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGfreqOnVirtChan.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m
