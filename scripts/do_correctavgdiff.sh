#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_correctavgdiff
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_correctavgdiff.sh
# useqsub=false
# shortLabel=cAvD

### Script ###

# Input Variables and Paths #
threshold=0.975
dev_range=2

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
DIR=$1/..
FREESURFER_HOME=/opt/freesurfer/5.3
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export PATH=$FREESURFER_HOME/bin:$PATH
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltktixblt/lib/:$LD_LIBRARY_PATH
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
fi
cd $DIR
unameOut='$(uname -s)'
case '${unameOut}' in
Linux*)         machine=Linux;;
Darwin*)        machine=Mac
esac
if [ '${machine}' == 'Mac' ]
then
echo setting freesurfer up for mac ...
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
else
echo setting freesurfer up for linux...
FREESURFER_HOME=/opt/freesurfer/5.3
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export PATH=$FREESURFER_HOME/bin:$PATH
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltktixblt/lib/:$LD_LIBRARY_PATH
fi
export SUBJECTS_DIR=$DIR
DIR=$DIR/2_coregistration
cd $DIR
max_=$(fslstats MCTemplate.nii.gz -R | awk '{print $2}')
min_=$(fslstats MCTemplate.nii.gz -R | awk '{print $1}')
diff_=$(echo "$max_ - $min_" | bc)
max_=$(echo "$min_ + $diff_ * $threshold" | bc )
echo cutting upper $threshold %...
fslmaths MCTemplate.nii.gz -uthr $max_ MCTemplateThr.nii.gz
echo done.
echo making lowest value zeros...
fslmaths MCTemplateThr.nii.gz -sub $min_ MCTemplateThr.nii.gz
echo done.
echo cutting upper $threshold %...
max_=$(fslstats MCTemplateThr.nii.gz -R | awk '{print $2}')
max_=$(echo "$max_ * $threshold" | bc)
range_shift=$(echo "$max_ / $dev_range" | bc)
fslmaths MCTemplateThr.nii.gz -uthr $max_ MCTemplateThr.nii.gz
fslmaths MCTemplateThr.nii.gz -sub $range_shift MCTemplateThrCont.nii.gz
fslmaths MCTemplateThrCont.nii.gz -thr 0 MCTemplateThrCont.nii.gz
echo done.


