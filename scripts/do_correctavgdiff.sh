#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_coregistration
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_coregistration"

fi

cd $DIR

max_=$(fslstats MCTemplate.nii.gz -R | awk '{print $2}')
min_=$(fslstats MCTemplate.nii.gz -R | awk '{print $1}')

diff_=$(echo "$max_ - $min_" | bc)

max_=$(echo "$min_ + $diff_ * $1" | bc )

echo cutting upper $1 %...
fslmaths MCTemplate.nii.gz -uthr $max_ MCTemplateThr.nii.gz
echo done.

echo making lowest value zeros...
fslmaths MCTemplateThr.nii.gz -sub $min_ MCTemplateThr.nii.gz
echo done.

echo cutting upper $1 %...
max_=$(fslstats MCTemplateThr.nii.gz -R | awk '{print $2}')
max_=$(echo "$max_ * $1" | bc)
fslmaths MCTemplateThr.nii.gz -uthr $max_ MCTemplateThr.nii.gz
echo done.

