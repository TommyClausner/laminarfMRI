#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_coregistration
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_coregistration"

fi

cd $DIR

cp $DIR/../1_realignment/all_functionals_stacked_mcf.nii.gz $DIR/functionals.nii.gz

lineidxsparse=$(cat $DIR/../A_helperfiles/numberofvolumes.txt | grep -n sparse | awk -F":" '{print $1}')

numvols=$(cat $DIR/../A_helperfiles/numberofvolumes.txt | grep sparse | awk -F" " '{print $1}')

numberallscans=$(cat $DIR/../A_helperfiles/numberofvolumes.txt | awk -F" " '{print $1}')
for i in `seq 1 $(echo $lineidxsparse | wc -w)`
do
curridx=$(echo $lineidxsparse | awk '{print '$(echo "$"$i)'}')
startfrom=0
for n in `seq 1 $(expr $curridx - 1)`
do
startfrom=$(expr $(echo $numberallscans | awk '{print '$(echo "$"$n)'}') + $startfrom)
done

currsize=$(echo $numberallscans | awk '{print '$(echo "$"$(echo $lineidxsparse | awk '{print '$(echo "$"$i)'}'))'}')
fslroi $DIR/functionals.nii.gz $DIR/sparse$i $startfrom $currsize

done
fslmerge -t $DIR/MCTemplatepre $DIR/*sparse*

mkdir $DIR/tmp

numvols=$(fslval $DIR/MCTemplatepre.nii.gz dim4)

numvols=$(expr $numvols - 1)

for i in `seq 0 4 $numvols`
do
j=$(expr $i + 3)
fslroi $DIR/MCTemplatepre.nii.gz $DIR/tmp/first $i 1
fslroi $DIR/MCTemplatepre.nii.gz $DIR/tmp/fourth $j 1
fslmaths $DIR/tmp/fourth -sub $DIR/tmp/first $DIR/tmp/diff$i

done

fslmerge -t $DIR/MCTemplateprediff $DIR/tmp/*diff*

fslmaths $DIR/MCTemplateprediff -Tmean $DIR/MCTemplate

rm -r $DIR/tmp
