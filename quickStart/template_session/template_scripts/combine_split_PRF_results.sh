#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=combine_split_PRF_results
# file=combine_split_PRF_results.sh
# useqsub=false
# shortLabel=combR

### Script ###

# Input Variables and Paths #
Nparts=80

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=matlab
walltime="04:00:00"
memory=64gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';numparts=$Nparts;">$DIR/tmp_$nameadd.m
cat $DIR/combine_split_PRF_results.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017a -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"');"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m


