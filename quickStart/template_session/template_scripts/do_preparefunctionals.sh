#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_preparefunctionals
# file=do_preparefunctionals.sh
# useqsub=true
# shortLabel=prfct

### Script ###

# Input Variables and Paths #
VolsBlock=3

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=batch
walltime="4:00:00"
memory=16gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../rawData/niftis/functionals
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../rawData/niftis/functionals"

fi

cd $DIR

FILES=$DIR/*sparse*
for f in $FILES
do
size_curr=$(fslval $f dim4)
filename=$(echo $f |rev | cut -d '/' -f1 | rev)
if (($size_curr > 182))
then
echo selecting ROI for $f...
mv $f $DIR/old/$filename
fslroi $DIR/old/$filename $f 0 -1 0 -1 0 -1 $VolsBlock 180
else
echo number of volumes must be greater than 182
fi
done

FILES=$DIR/*retino*
for f in $FILES
do
size_curr=$(fslval $f dim4)
filename=$(echo $f |rev | cut -d '/' -f1 | rev)
if (($size_curr > 127))
then
echo selecting ROI for $f...
mv $f $DIR/old/$filename
fslroi $DIR/old/$filename $f 0 -1 0 -1 0 -1 0 128
else
echo number of volumes must be greater than 127
fi
done

echo done.

