#!/bin/bash

# FSL distortion correction using topup

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../3_distcorrection
if [[ $# -lt 2 ]]
then
include_coreg=0
else
include_coreg=$2
fi


else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../3_distcorrection"
if [[ $# -lt 1 ]]
then
include_coreg=0
else
include_coreg=$1
fi

fi

cd $DIR
mkdir refvolumes


echo selecting inverted images...
inverted_=$(ls $DIR/../1_realignment/inverted_mcf0.nii.gz)
num_vols_inv=$(fslval $inverted_ dim4)
echo averaging...
fslmaths $inverted_ -Tmean $DIR/refvolumes/invertedavg
echo done.

echo selecting normal images...
stacked_fcnls=$(ls $DIR/../1_realignment/*task_mcf*.nii.gz | tail -1)

num_vols_norm=$(fslval $stacked_fcnls dim4)

sel_slices=$(seq $(($num_vols_norm-1)) -4 $(($(($num_vols_norm-1))-4*($num_vols_inv-1))))

mkdir $DIR/tmp 

for i in `seq 1 $num_vols_inv`
do
echo $i
echo $(echo $sel_slices | cut -d' ' -f$i)
fslroi $stacked_fcnls  $DIR/tmp/normal$i 0 -1 0 -1 0 -1 $(echo $sel_slices | cut -d' ' -f$i) 1
done

fslmerge -t $DIR/refvolumes/normalavg $DIR/tmp/*.nii.gz

rm -r $DIR/tmp
echo averaging...
fslmaths $DIR/refvolumes/normalavg -Tmean $DIR/refvolumes/normalavg
echo done.

fslmerge -t $DIR/all_b0 $DIR/refvolumes/*.nii.gz

if [[ include_coreg -eq 1 ]]
then
flirt -applyxfm -in $DIR/all_b0.nii.gz -ref $DIR/all_b0.nii.gz -init $DIR/../2_coregistration/transmatconv.txt -out all_b0.nii.gz
fi

echo estimating field distortion...
topup --imain=$DIR/all_b0.nii.gz --datain=$DIR/../A_helperfiles/acquisition_parameters.txt --config=$DIR/../A_helperfiles/b02b0.cnf --out=$DIR/topup_results_out --fout=$DIR/topup_field_out --iout=$DIR/topup_unwarped_images_out
echo done.
