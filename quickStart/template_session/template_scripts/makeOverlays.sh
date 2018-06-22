#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=makeOverlays
# file=/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/makeOverlays.sh
# useqsub=true
# shortLabel=OvlyMp

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
mri_vol2surf --src $DIR/4_retinotopy/ang_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi lh --surf pial --out $DIR/4_retinotopy/lh.ang.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/ang_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi rh --surf pial --out $DIR/4_retinotopy/rh.ang.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/ecc_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi lh --surf pial --out $DIR/4_retinotopy/lh.ecc.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/ecc_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi rh --surf pial --out $DIR/4_retinotopy/rh.ecc.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/xpos_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi lh --surf pial --out $DIR/4_retinotopy/lh.xpos.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/xpos_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi rh --surf pial --out $DIR/4_retinotopy/rh.xpos.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/ypos_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi lh --surf pial --out $DIR/4_retinotopy/lh.ypos.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/ypos_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi rh --surf pial --out $DIR/4_retinotopy/rh.ypos.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/r2_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi lh --surf pial --out $DIR/4_retinotopy/lh.r2.mgh --out_type paint
mri_vol2surf --src $DIR/4_retinotopy/r2_map.nii  --srcreg $DIR/2_coregistration/bbregister.dat --hemi rh --surf pial --out $DIR/4_retinotopy/rh.r2.mgh --out_type paint


