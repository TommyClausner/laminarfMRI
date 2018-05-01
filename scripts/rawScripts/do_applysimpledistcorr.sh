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

echo applying distortion correction...

for d in $DIR/../1_realignment/*_mcf*.mat
do
currname=$(basename $d .mat | rev | cut -c 2- | rev)
currnum=$(basename $d .mat | sed -e s/[^0-9]//g)
currname=$(echo "$currname$currnum")

applytopup --imain=$DIR/../1_realignment/$currname --datain=$DIR/../A_helperfiles/acquisition_parameters.txt --inindex=2 --topup=topup_results_out --method=jac --out=$DIR/corrected_test_$currname

done
echo done.
