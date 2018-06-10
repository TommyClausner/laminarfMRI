#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGprepareHeadmodel
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_EEGprepareHeadmodel.sh
# useqsub=false
# shortLabel=EEGprHM

### Script ###

# Input Variables and Paths #
Model=FEM

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="11:59:59"
memory=31gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';conductModel='$Model';">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGprepareHeadmodel.m>>$DIR/tmp_$nameadd.m
echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
rm $DIR/tmp_$nameadd.m



