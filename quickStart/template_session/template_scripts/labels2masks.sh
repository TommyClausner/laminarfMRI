#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=labels2masks
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/labels2masks.sh
# useqsub=false
# shortLabel=La2msk

### Script ###

# Input Variables and Paths #
refVol=MCTemplate.nii.gz

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
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltkt$
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
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltkt$
fi
export SUBJECTS_DIR=$DIR
mri_label2vol --label $DIR/0_freesurfer/label/lh.V1.ret.label --temp $DIR/3_coregistration/$refVol --reg $DIR/3_coregistration/bbregister.dat --o $DIR/4_retinotopy/lhV1mask.nii.gz
mri_label2vol --label $DIR/0_freesurfer/label/rh.V1.ret.label --temp $DIR/3_coregistration/$refVol --reg $DIR/3_coregistration/bbregister.dat --o $DIR/4_retinotopy/rhV1mask.nii.gz
mri_label2vol --label $DIR/0_freesurfer/label/lh.V2.ret.label --temp $DIR/3_coregistration/$refVol --reg $DIR/3_coregistration/bbregister.dat --o $DIR/4_retinotopy/lhV2mask.nii.gz
mri_label2vol --label $DIR/0_freesurfer/label/rh.V2.ret.label --temp $DIR/3_coregistration/$refVol --reg $DIR/3_coregistration/bbregister.dat --o $DIR/4_retinotopy/rhV2mask.nii.gz
mri_label2vol --label $DIR/0_freesurfer/label/lh.V3.ret.label --temp $DIR/3_coregistration/$refVol --reg $DIR/3_coregistration/bbregister.dat --o $DIR/4_retinotopy/lhV3mask.nii.gz
mri_label2vol --label $DIR/0_freesurfer/label/rh.V3.ret.label --temp $DIR/3_coregistration/$refVol --reg $DIR/3_coregistration/bbregister.dat --o $DIR/4_retinotopy/rhV3mask.nii.gz






