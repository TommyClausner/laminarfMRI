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
walltime="11:59:59"
memory=62gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

if [ "$#" -ne 2 ]
then
blocks="[1,2,3,4]"
filt=1
else
blocks=$1
filt=$2
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "start beamformer for block $blocks, filter $filt"
echo "mainpath=" "'$DIR';headmodelType='$Model';BlockSel=$blocks;FiltSel=$filt;">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGbeamformer.m>>$DIR/tmp_$nameadd.m
echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
rm $DIR/tmp_$nameadd.m



