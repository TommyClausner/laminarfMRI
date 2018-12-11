#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGsplitBeamformer
# file=do_EEGsplitBeamformer.sh
# useqsub=false
# shortLabel=spBeam

### Script ###

# Input Variables and Paths #
splitparts=4

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=batch
walltime="24:00:00"
memory=32gb

# Misc Variables #
NewMiscVar0=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
for k in `seq 1 2`
do
for i in `seq 1 $splitparts`
do
$DIR/do_EEGbeamformer.sh $i $k &
sleep 2s
if [[ $i -eq 1 ]]
then
PIDstart=$(qstat | awk -F' ' '{print $1}' | tail -1 | cut -d"." -f1)
fi
done
done
PIDend=$(qstat | awk -F' ' '{print $1}' | tail -1 | cut -d"." -f1)
while [[ $(qstat -u tomcla | grep -o [R,Q] | wc -l) -gt 2 ]] 
#because two header lines
do 
sleep 60s
done
sh $DIR/do_EEGsplitVirtualChannel.sh
