#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../C_miscResults
input=$3
file=$2
else
input=$2
file=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../C_miscResults"

fi

cd $DIR

mask="fullmask"

if [ $# -eq 2 ]
then
    	if [[ ${input:0:1} == '/' ]]
        then
	echo no mask selected
	fslmaths $DIR/../2_coregistration/MCTemplate.nii.gz -bin $DIR/../2_coregistration/fullmask.nii.gz
        else
	mask=$input
        echo using the following mask $input
        fi

elif [ $# -eq 3 ]
then
mask=$3
echo using the following mask $3
else
echo no mask selected            

fi

fslmeants -i $DIR/$file -o avgvolumeovertime$mask.txt -m $DIR/../2_coregistration/$mask.nii.gz
