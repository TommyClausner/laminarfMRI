#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/..
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

fi

cd $DIR

mkdir A_helperfiles

mkdir B_scripts

mkdir C_miscResults

mkdir 0_freesurfer

mkdir 1_realignment

mkdir 2_coregistration

mkdir 3_distcorrection
mkdir 3_distcorrection/refvolumes

mkdir 4_retinotopy

mkdir 5_laminar

mkdir niftis
mkdir niftis/functionals
mkdir niftis/functionals/old
mkdir niftis/t1
mkdir niftis/inverted
mkdir niftis/pd
mkdir niftis/pdinverted
