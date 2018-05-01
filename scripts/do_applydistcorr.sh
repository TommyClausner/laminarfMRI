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

stacked_fcnls=$(ls $DIR/../1_realignment/*_mcf.nii*)

echo applying distortion correction...
applytopup --imain=$stacked_fcnls --datain=$DIR/../A_helperfiles/acquisition_parameters.txt --inindex=2 --topup=topup_results_out --method=jac --out=applytopup_results_out
echo done.
