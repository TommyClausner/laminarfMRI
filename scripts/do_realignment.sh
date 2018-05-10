#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_realignment
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_realignment.sh
# useqsub=true
# shortLabel=Real

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
DIR=$1/../1_realignment
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../1_realignment"
fi
echo $DIR
mkdir $DIR
cd $DIR
rm $DIR/../A_helperfiles/numberofvolumes.txt
touch $DIR/../A_helperfiles/numberofvolumes.txt
for scan in $DIR/../rawData/niftis/functionals/*.nii*
do
a=${a#*ep2d}
name_="$scan"
name_=${name_#*ep2d}
name_=${name_%a[0-9]*}
echo "$(echo $(fslinfo $scan | grep -w dim4) | cut -f2 -d' ') $name_" >> $DIR/../A_helperfiles/numberofvolumes.txt
done
echo merging volumes...
fslmerge -t all_functionals_stacked $DIR/../rawData/niftis/functionals/*sparse*
fslmaths all_functionals_stacked -Tmean $DIR/meanvol
echo done.
rm -r $DIR/*all_functionals_stacked*
echo doing motion correction...
i=0
for f in $DIR/../rawData/niftis/functionals/*retino*
do
cp $f $DIR/ret$i.nii.gz
mcflirt -in $f -reffile $DIR/meanvol -mats -out $DIR/ret_mcf$i
i=$(($i+1))
done
i=0
for f in $DIR/../rawData/niftis/functionals/*sparse*
do
cp $f $DIR/task$i.nii.gz
mcflirt -in $f -reffile $DIR/meanvol -mats -out $DIR/task_mcf$i
i=$(($i+1))
done
i=0
for f in $DIR/../rawData/niftis/inverted/*inverted*
do
cp $f $DIR/inverted$i.nii.gz
mcflirt -in $f -reffile $DIR/meanvol -mats -out $DIR/inverted_mcf$i
i=$(($i+1))
done
echo done.


