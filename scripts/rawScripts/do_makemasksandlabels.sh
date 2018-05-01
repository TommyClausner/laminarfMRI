#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_coregistration
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_coregistration"

fi

cd $DIR

input=$1
orient=""

if [ $# -eq 1 ]
then
    	if [[ ${input:0:1} == '/' ]]
        then
	echo using nifti file orientation
        else
        orient="--out_orientation $input"
	echo using the following orientation parameter $input
        fi

elif [ $# -eq 2 ]
then
orient="--out_orientation $2"
echo using the following orientation parameter $2
else
echo using nifti file orientation 
fi

#optional --out_orientation PSL or RAS or you name it
mri_convert $orient -rt nearest --reslice_like $DIR/../niftis/t1/* $DIR/../0_freesurfer/mri/orig.mgz t1.nii.gz
mri_convert $orient -rt nearest --reslice_like $DIR/../niftis/t1/* $DIR/../0_freesurfer/mri/ribbon.mgz t1ribbon.nii.gz
mri_convert $orient -rt nearest --reslice_like $DIR/../niftis/t1/* $DIR/../0_freesurfer/mri/brain.mgz t1brain.nii.gz
mri_convert $orient -rt nearest --reslice_like $DIR/../niftis/t1/* $DIR/../0_freesurfer/mri/aparc+aseg.mgz t1segmented.nii.gz

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
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1.nii.gz $DIR/transmat.txt $DIR/t1coreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1brain.nii.gz $DIR/transmat.txt $DIR/t1braincoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1segmented.nii.gz $DIR/transmat.txt $DIR/t1segmentedcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1class.nii.gz $DIR/transmat.txt $DIR/t1classcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/t1ribbon.nii.gz $DIR/transmat.txt $DIR/t1ribboncoreg.nii.gz

$DIR/../B_scripts/do_movesinglevolume.sh $DIR/whitemattermask.nii.gz $DIR/transmat.txt $DIR/whitemattermaskcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/graymattermask.nii.gz $DIR/transmat.txt $DIR/graymattermaskcoreg.nii.gz
$DIR/../B_scripts/do_movesinglevolume.sh $DIR/csfmask.nii.gz $DIR/transmat.txt $DIR/csfmaskcoreg.nii.gz

flirt -in $DIR/t1coreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctcoreg.nii.gz
flirt -in $DIR/t1braincoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctbraincoreg.nii.gz
flirt -in $DIR/t1classcoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctclasscoreg.nii.gz
flirt -in $DIR/t1segmentedcoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctsegmentedcoreg.nii.gz
flirt -in $DIR/t1ribboncoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctribboncoreg.nii.gz

flirt -in $DIR/whitemattermaskcoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctwhitemattercoreg.nii.gz
flirt -in $DIR/graymattermaskcoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctgraymattercoreg.nii.gz
flirt -in $DIR/csfmaskcoreg.nii.gz -ref $DIR/MCTemplateThr.nii.gz -init $DIR/transmat.txt -out $DIR/fctcsfcoreg.nii.gz

