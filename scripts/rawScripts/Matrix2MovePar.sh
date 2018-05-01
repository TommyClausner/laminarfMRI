#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

volinfo=$(echo $(fslinfo $DIR/../1_realignment/ret0.nii.gz | grep dim*[1-3] | awk  '{print $2}'))
echo $volinfo
for d in $DIR/../1_realignment/*_mcf*.mat
do
mkdir $d/topupformat
for f in $d/*MAT_*
do
name_=$(basename $f)
python Matrix2MovePar.py $f "$volinfo">$d/topupformat/$name_
done
done
