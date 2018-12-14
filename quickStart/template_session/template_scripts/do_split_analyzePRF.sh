#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_split_analyzePRF
# file=do_split_analyzePRF.sh
# useqsub=false
# shortLabel=saPRF

### Script ###

# Input Variables and Paths #
splitparts=80

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
for i in `seq 1 $splitparts`
do

if [[ $i -eq 1 ]]
then
PIDstart=$($DIR/do_analyzePRF.sh $i $splitparts &)
elif [[ $i -eq $splitparts ]]
then
PIDend=$($DIR/do_analyzePRF.sh $i $splitparts &)
else
$DIR/do_analyzePRF.sh $i $splitparts &
fi
sleep 2s
done

sh $DIR/waitForJobs.sh $PIDstart $PIDend


