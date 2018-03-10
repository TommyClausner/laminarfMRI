#!/bin/bash

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../3_distcorrection
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../3_distcorrection"

fi

cd $DIR

mkdir $DIR/transmatstoapply

$DIR/../B_scripts/multiply_all_M_in_A_with_B.sh ../1_realignment/all_functionals_stacked_mcf.mat ../2_coregistration/transmat.txt

$DIR/../B_scripts/transmats2topup.sh ../1_realignment/all_functionals_stacked_mcf.mat/matmulResults

motioncortransmats=$DIR/../1_realignment/all_functionals_stacked_mcf.mat/matmulResults/topupformat

awk '/./{line=$0} END{print line}' $DIR/topup_results_out_movpar.txt > $DIR/topup_results_out_movpar_onlyfct.txt

distcortransmats=$DIR/topup_results_out_movpar_onlyfct.txt

for f in $motioncortransmats/*
do 

name=$(basename "$f")

echo "0  0  0  0  0  0"$'\r' > $DIR/transmatstoapply/$name

sh $DIR/../B_scripts/mergetransforms.sh $f $distcortransmats >> $DIR/transmatstoapply/$name
done
