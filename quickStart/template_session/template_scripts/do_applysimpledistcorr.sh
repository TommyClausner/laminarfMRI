#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_applysimpledistcorr
# file=do_applysimpledistcorr.sh
# useqsub=true
# shortLabel=aDC

### Script ###

# Input Variables and Paths #
InputVarName=none

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=batch
walltime="24:00:00"
memory=32gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_distcorrection
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_distcorrection"
fi
cd $DIR
echo applying distortion correction...
for d in $DIR/../1_realignment/*_mcf*.mat
do
currname=$(basename $d .mat | rev | cut -c 2- | rev)
currnum=$(basename $d .mat | sed -e s/[^0-9]//g)
currname=$(echo "$currname$currnum")
applytopup --imain=$DIR/../1_realignment/$currname --datain=$DIR/../A_helperfiles/acquisition_parameters.txt --inindex=2 --topup=topup_results_out --method=jac --out=$DIR/corrected_$currname
done
echo done.


