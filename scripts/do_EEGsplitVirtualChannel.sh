#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGsplitvirtualChannel
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_EEGsplitvirtualChannel.sh
# useqsub=false
# shortLabel=spvirtCh

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
for j in `seq 1 2`
do
for i in `seq 1 $splitparts`
do
$DIR/do_EEGvirtualChannel.sh $i $j &
sleep 2s
done
done



