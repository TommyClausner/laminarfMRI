#!/bin/bash

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../3_distcorrection
if [[ $# -lt 2 ]]
then
include_coreg=0
else
include_coreg=$2
fi

else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../3_distcorrection"
if [[ $# -lt 1 ]]
then
include_coreg=0
else
include_coreg=$1
fi

fi

cd $DIR

mkdir $DIR/transmatstoapply

cp -r $DIR/../1_realignment/*.mat $DIR/transmatstoapply/

if [[ $include_coreg -eq 1 ]]
then
for d in $DIR/transmatstoapply/*
do
$DIR/../B_scripts/multiply_all_M_in_A_with_B.sh $d ../2_coregistration/transmatconv.txt

$DIR/../B_scripts/transmats2topup.sh $d/matmulResults

done

else
for d in $DIR/transmatstoapply/*
do
$DIR/../B_scripts/transmats2topup.sh $d

done
fi
awk '/./{line=$0} END{print line}' $DIR/topup_results_out_movpar.txt > $DIR/topup_results_out_movpar_onlyfct.txt

distcortransmats=$DIR/topup_results_out_movpar_onlyfct.txt

for d in $DIR/transmatstoapply/*
do
for f in $d/topupformat/*
do 

name=$(basename "$f")

echo "0  0  0  0  0  0"$'\r' > $d/tmp$name

sh $DIR/../B_scripts/mergetransforms.sh $f $distcortransmats >> $d/tmp$name
mv $d/tmp$name $d/$name
done
done
