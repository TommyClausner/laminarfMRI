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
for l in `seq 1 2`
do
for k in `seq 1 2`
do
for i in `seq 1 $splitparts`
do
$DIR/do_EEGbeamformer.sh $i $k $l &
sleep 2s
done
done
done

while [[ $(ls $DIR | grep tmp_ | wc -l) -gt 0 ]]
do
sleep 61s
done
sh $DIR/do_EEGsplitVirtualChannel.sh

