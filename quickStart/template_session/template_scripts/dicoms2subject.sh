#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../rawData/niftis"

dataDir=$1

dcm2nii $dataDir

cp $dataDir/*Retino*.nii* $DIR/functionals/
cp $dataDir/*silent*.nii* $DIR/functionals/

cp $dataDir/*t1*.nii* $DIR/t1/

cp $dataDir/*retino*inverted*.nii* $DIR/inverted/

cp $dataDir/*3D*whole*.nii* $DIR/wholeBrainEPI3D/
cp $dataDir/*3D*whole*INVERTED*.nii* $DIR/wholeBrainEPI3Dinverted/
