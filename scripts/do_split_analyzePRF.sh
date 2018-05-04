#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_split_analyzePRF
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_split_analyzePRF.sh
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
$DIR/do_analyzePRF.sh $i $splitparts &
sleep 2s
if [[ $i -eq 1 ]]
then
PIDstart=$(qstat | awk -F' ' '{print $1}' | tail -1 | cut -d"." -f1)
fi
done
PIDend=$(qstat | awk -F' ' '{print $1}' | tail -1 | cut -d"." -f1)
sh $DIR/waitForJobs.sh $PIDstart $PIDend


