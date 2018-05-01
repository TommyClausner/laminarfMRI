#!/bin/bash

# FSL distortion correction using applytopup

### arguments after sh do_applydistcorr.sh

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../3_distcorrection
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../3_distcorrection"

fi

cd $DIR

mkdir $DIR/applytopupresults

echo applying distortion correction...

rm $DIR/tmp.nii.gz
for d in $DIR/transmatstoapply/*
do
i=0
currname=$(basename $d .mat | rev | cut -c 6- | rev)
currnum=$(basename $d .mat | sed -e s/[^0-9]//g)
currname=$(echo "$currname$currnum")

mkdir $DIR/applytopupresults/$currname
for f in $d/*.txt
do
cp $DIR/topup_results_out_movpar.txt $DIR/tmpbackup.txt
cp $f $DIR/topup_results_out_movpar.txt

fslroi $DIR/../1_realignment/$currname $DIR/tmp 0 -1 0 -1 0 -1 $i 1

applytopup --imain=$DIR/tmp --datain=$DIR/../A_helperfiles/acquisition_parameters.txt --inindex=2 --topup=topup_results_out --method=jac --out=$DIR/applytopupresults/$currname/$i
i=$(($i+1))
rm $DIR/tmp.nii.gz
mv $DIR/tmpbackup.txt $DIR/topup_results_out_movpar.txt
done

fslmerge -t $DIR/corrected_$currname $DIR/applytopupresults/$currname/*
done
rm -r $DIR/applytopupresults
echo done.
