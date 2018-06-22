#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_preparecoregistrationQsub.sh
# useqsub=true
# label=do_preparecoregistrationQsub
# ThreeLetter=ROQ

### Script ###

# Input Variables and Paths #
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ScriptToRun=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_preparecoregistration.sh

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=batch
walltime="24:00:00"
memory=16gb

# Misc Variables #
MiscVar=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
qsub -q $jobtype -l walltime=$walltime,mem=$memory -F "$DIR ${@:1}" $ScriptToRun
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done

