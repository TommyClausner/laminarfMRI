#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_getLayers
# file=do_getLayers.sh
# useqsub=false
# shortLabel=Layers

### Script ###

# Input Variables and Paths #
registerTo=MCTemplateThrCont.nii
Nlayers=3

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
nameadd=$(date +"%m%d%Y%H%M%S")
echo "mainpath=" "'$DIR';numLayers=$Nlayers;regvol='`basename $registerTo .nii`'">$DIR/tmp_$nameadd.m
cat $DIR/do_getLayers.m>>$DIR/tmp_$nameadd.m
PIDqsub=$(echo 'matlab2017b -nosplash -nodesktop -r "run('"'"$DIR/tmp_$nameadd.m"'"')"' | qsub -q $jobtype -l walltime=$walltime,mem=$memory)

sh waitForQsubPID.sh $PIDqsub

rm $DIR/tmp_$nameadd.m



