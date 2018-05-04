#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_preparecoregistration
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_preparecoregistration.sh
# useqsub=true
# shortLabel=prCo

### Script ###

# Input Variables and Paths #
InputVarName=none

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=batch
walltime="24:00:00"
memory=16gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_coregistration
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_coregistration"
fi
cd $DIR

fslmerge -t $DIR/MCTemplatepre $DIR/../3_distcorrection/*corrected_task*.nii*

mkdir $DIR/tmp
numvols=$(fslval $DIR/MCTemplatepre.nii.gz dim4)
numvols=$(expr $numvols - 1)
for i in `seq 0 4 $numvols`
do
j=$(expr $i + 3)
fslroi $DIR/MCTemplatepre.nii.gz $DIR/tmp/first $i 1
fslroi $DIR/MCTemplatepre.nii.gz $DIR/tmp/fourth $j 1
fslmaths $DIR/tmp/fourth -sub $DIR/tmp/first $DIR/tmp/diff$i
done
rm $DIR/MCTemplatepre.nii.gz
fslmerge -t $DIR/MCTemplateprediff $DIR/tmp/*diff*
fslmaths $DIR/MCTemplateprediff -Tmean $DIR/MCTemplate
rm $DIR/MCTemplateprediff.nii.gz
rm -r $DIR/tmp


