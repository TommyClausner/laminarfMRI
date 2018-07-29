#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_EEGfreqChanSelect
# file=do_EEGfreqChanSelect.sh
# useqsub=false
# shortLabel=EEGfrChS

### Script ###

# Input Variables and Paths #
InputVarName=none

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="11:59:59"
memory=256gb

# Misc Variables #
deleteOldFiles=1

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';clean_EEG_folder=$deleteOldFiles;">$DIR/tmp_$nameadd.m
cat $DIR/do_EEGfreqChanSelect.m>>$DIR/tmp_$nameadd.m
echo 'matlab2017b -nosplash -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory
PIDqsub=$(qstat | awk -F' ' '{print $1}' | tail -1)
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
while [ "$statusqsub" != "C" ]
do
sleep 1s
statusqsub=$(qstat $PIDqsub | awk -F' ' '{print $5}' | tail -1)
done
rm $DIR/tmp_$nameadd.m



