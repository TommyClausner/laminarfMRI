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

mkdir 2_distcorrection
mkdir 2_distcorrection/refvolumes

mkdir 3_coregistration

mkdir 4_retinotopy

mkdir 5_laminar

mkdir 6_EEG

mkdir 7_results

mkdir rawData
mkdir rawData/eegfiles
mkdir rawData/eyetrackerfiles
mkdir rawData/electrodes
mkdir rawData/electrodes/photogrammetry
mkdir rawData/electrodes/photogrammetry/photographs
mkdir rawData/electrodes/photogrammetry/photographs/masks
mkdir rawData/electrodes/photogrammetry/photoscanfiles
mkdir rawData/electrodes/photogrammetry/3Dobject
mkdir rawData/electrodes/polhemus
mkdir rawData/niftis
mkdir rawData/niftis/functionals
mkdir rawData/niftis/functionals/old
mkdir rawData/niftis/t1
mkdir rawData/niftis/inverted
mkdir rawData/niftis/wholeBrainEPI3D
mkdir rawData/niftis/wholeBrainEPI3Dinverted
mkdir rawData/retinotopy
