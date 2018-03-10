#!/bin/bash

# FSL realignment

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../1_realignment
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../1_realignment"

fi

echo $DIR
mkdir $DIR
cd $DIR

rm $DIR/../A_helperfiles/numberofvolumes.txt
touch $DIR/../A_helperfiles/numberofvolumes.txt

for scan in $DIR/../niftis/functionals/*.nii*
do
a=${a#*ep2d}
name_="$scan"
name_=${name_#*ep2d}
name_=${name_%a[0-9]*}
echo "$(echo $(fslinfo $scan | grep -w dim4) | cut -f2 -d' ') $name_" >> $DIR/../A_helperfiles/numberofvolumes.txt

done

echo merging volumes...
fslmerge -t all_functionals_stacked $DIR/../niftis/functionals/*.nii*
echo done.

echo doing motion correction...
mcflirt -in all_functionals_stacked -meanvol -mats
echo done.
