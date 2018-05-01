#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../4_retinotopy
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../4_retinotopy"

fi

cd $DIR

cp $DIR/../1_realignment/all_functionals_stacked_mcf.nii.gz $DIR/functionals.nii.gz

startvol=$(cat $DIR/../A_helperfiles/numberofvolumes.txt | grep -n retinotopy | awk -F":" '{print $1}' | head -n 1)

startvol=$(expr $startvol - 1)

echo $startvol

numvols=$(cat $DIR/../A_helperfiles/numberofvolumes.txt | grep retinotopy | awk -F" " '{print $1}')

sum=0
for i in $numvols
do
sum=$(expr $sum + $i)
done

numvols=$sum

echo $numvols

fslroi $DIR/functionals $DIR/ret 0 -1 0 -1 0 -1 $startvol $numvols

echo preparing nifti...
num_uncomp_niftis=$(find / -type f -name "*.nii" | wc -l)

if [ $num_uncomp_niftis -lt 1 ]
then
gunzip -f -c $DIR/ret.nii.gz >$DIR/ret.nii
fi
echo done.

