#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGsplitFreqOnVirtChan
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_EEGsplitFreqOnVirtChan.sh
# useqsub=false
# shortLabel=spFreq

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
for j in `seq 1 2`
do
for i in `seq 1 $splitparts`
do
$DIR/do_EEGfreqOnVirtChan.sh $i $j $k &
sleep 2s
done
done
done



