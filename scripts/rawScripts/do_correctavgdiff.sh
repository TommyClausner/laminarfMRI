#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_coregistration
threshold=$2
if [[ $# -lt 3 ]]
then
dev_range=2
else
dev_range=$3
fi
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_coregistration"
threshold=$1
if [[ $# -lt 2 ]]
then
dev_range=2  
else
dev_range=$2
fi

fi

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

