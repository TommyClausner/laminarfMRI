#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_tseriesinterpolation
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_tseriesinterpolation.sh
# useqsub=false
# shortLabel=Tsint

### Script ###

# Input Variables and Paths #
Nblocks=3
mskThr=0.01
TR=2.7
StimSize=100

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
echo "mainpath=" "'$DIR';numblocks=$Nblocks;mask_threshold=$mskThr;TR=$TR;size_stims_new=$StimSize;">$DIR/tmp_$nameadd.m
cat $DIR/do_tseriesinterpolation.m>>$DIR/tmp_$nameadd.m
echo 'matlab2013a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
rm $DIR/tmp_$nameadd.m

