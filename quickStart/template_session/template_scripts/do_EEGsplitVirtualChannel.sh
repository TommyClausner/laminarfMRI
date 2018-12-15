#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGsplitvirtualChannel
# file=do_EEGsplitvirtualChannel.sh
# useqsub=false
# shortLabel=spvirtCh

### Script ###

# Input Variables and Paths #
blocks=4

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
for i in `seq 1 $blocks`
do
$DIR/do_EEGvirtualChannel.sh $i $j $k &
sleep 2s
done
done
done



