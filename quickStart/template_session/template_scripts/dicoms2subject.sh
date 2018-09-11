#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../rawData/niftis"

dataDir=$1

dcm2nii $dataDir

mv $dataDir/*Retino*.nii* $DIR/functionals/
mv $dataDir/*silent*.nii* $DIR/functionals/

mv $dataDir/[0-9]*t1*.nii* $DIR/t1/

mv $DIR/functionals/*inverted*.nii* $DIR/inverted/

mv $dataDir/*3dWhole*.nii* $DIR/wholeBrainEPI3D/
mv $DIR/wholeBrainEPI3D/*INVERTED*.nii* $DIR/wholeBrainEPI3Dinverted/
