#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=expandROIs
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/expandROIs.sh
# useqsub=false
# shortLabel=expROIs

### Script ###

# Input Variables and Paths #
ExpandBy=4
mskThr=0.01

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="48:00:00"
memory=64gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';ExpansionFactor=$ExpandBy;maskthreshold=$mskThr;">$DIR/tmp_$nameadd.m
cat $DIR/expandROIs.m>>$DIR/tmp_$nameadd.m
echo 'matlab2013a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
rm $DIR/tmp_$nameadd.m



