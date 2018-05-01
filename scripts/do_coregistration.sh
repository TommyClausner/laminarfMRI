#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_coregistration
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_coregistration.sh
# useqsub=false
# shortLabel=Coreg

### Script ###

# Input Variables and Paths #
registerTo=MCTemplateThrCont.nii.gz

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="24:00:00"
memory=32gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
cp $DIR/../2_coregistration/$registerTo $DIR/../2_coregistration/old$registerTo
gunzip $DIR/../2_coregistration/$registerTo
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';regvol='`basename $registerTo .gz`'">$DIR/tmp_$nameadd.m
cat $DIR/do_coregistration.m>>$DIR/tmp_$nameadd.m
echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"')"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
rm $DIR/tmp_$nameadd.m







