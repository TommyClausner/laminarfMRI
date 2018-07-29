#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=do_makemasksandlabels
# file=do_makemasksandlabels.sh
# useqsub=false
# shortLabel=masks

### Script ###

# Input Variables and Paths #
orient="--out_orientation RAS"
transmat=transmat.txt
refVolume=MCTemplateThrCont.nii.gz

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
Linux*)		machine=Linux;;
Darwin*)	machine=Mac
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
DIR=$DIR/3_coregistration
cd $DIR
#optional --out_orientation PSL or RAS or you name it
mri_convert $orient -rt nearest --reslice_like $DIR/../rawData/niftis/t1/* $DIR/../0_freesurfer/mri/orig.mgz t1.nii.gz
mri_convert $orient -rt nearest --reslice_like $DIR/../rawData/niftis/t1/* $DIR/../0_freesurfer/mri/ribbon.mgz t1ribbon.nii.gz
mri_convert $orient -rt nearest --reslice_like $DIR/../rawData/niftis/t1/* $DIR/../0_freesurfer/mri/brain.mgz t1brain.nii.gz
mri_convert $orient -rt nearest --reslice_like $DIR/../rawData/niftis/t1/* $DIR/../0_freesurfer/mri/aparc+aseg.mgz t1segmented.nii.gz
# create labeled volume for retinotopy
fslmaths t1ribbon.nii.gz -thr 2 -uthr 2 -bin -mul 3 lh.wm
fslmaths t1ribbon.nii.gz -thr 41 -uthr 41 -bin -mul 4 rh.wm
fslmaths t1ribbon.nii.gz -thr 3 -uthr 3 -bin -mul 5 lh.gm
fslmaths t1ribbon.nii.gz -thr 42 -uthr 42 -bin -mul 6 rh.gm
# create masks for CSF, gray matter and white matter
fslmaths t1segmented.nii.gz	-thr 24	-uthr 24 -bin csfmask.nii.gz
fslmaths t1ribbon.nii.gz -thr 2 -uthr 2 -bin lhmask.wm
fslmaths t1ribbon.nii.gz -thr 41 -uthr 41 -bin rhmask.wm
fslmaths t1ribbon.nii.gz	-thr 3 -uthr 3 -bin lhmask.gm
fslmaths t1ribbon.nii.gz	-thr 42	-uthr 42 -bin rhmask.gm
# merge labels to volume
fslmaths lh.wm -max lh.gm -max rh.wm -max rh.gm t1class.nii.gz
# merge masks
fslmaths lhmask.wm -max rhmask.wm whitemattermask.nii.gz
fslmaths lhmask.gm -max	rhmask.gm graymattermask.nii.gz
# remove temporary files
rm lh.wm.nii.gz lh.gm.nii.gz rh.wm.nii.gz rh.gm.nii.gz lhmask.wm.nii.gz rhmask.wm.nii.gz lhmask.gm.nii.gz rhmask.gm.nii.gz
# move towards coregistration space
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1.nii.gz $transmat $DIR/t1coreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1brain.nii.gz $transmat $DIR/t1braincoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1segmented.nii.gz $transmat $DIR/t1segmentedcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1class.nii.gz $transmat $DIR/t1classcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1ribbon.nii.gz $transmat $DIR/t1ribboncoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/whitemattermask.nii.gz $transmat $DIR/whitemattermaskcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/graymattermask.nii.gz $transmat $DIR/graymattermaskcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/csfmask.nii.gz $transmat $DIR/csfmaskcoreg.nii.gz
flirt -in $DIR/t1coreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctcoreg.nii.gz
flirt -in $DIR/t1braincoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctbraincoreg.nii.gz
flirt -in $DIR/t1classcoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctclasscoreg.nii.gz
flirt -in $DIR/t1segmentedcoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctsegmentedcoreg.nii.gz
flirt -in $DIR/t1ribboncoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctribboncoreg.nii.gz
flirt -in $DIR/whitemattermaskcoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctwhitemattercoreg.nii.gz
flirt -in $DIR/graymattermaskcoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctgraymattercoreg.nii.gz
flirt -in $DIR/csfmaskcoreg.nii.gz -ref $DIR/$refVolume -init $DIR/$transmat -out $DIR/fctcsfcoreg.nii.gz


