#!/bin/bash

# cut first 4 volumes + last x volumes that are overhanging of each dataset that exposes a certain name-size combination

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../niftis/functionals
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../niftis/functionals"

fi

cd $DIR

FILES=$DIR/*sparse*
for f in $FILES
do
size_curr=$(fslval $f dim4)

size_curr=$(expr $size_curr - $(expr $size_curr % 4))

filename=$(echo $f |rev | cut -d '/' -f1 | rev)

echo selecting ROI for $f...
mv $f $DIR/old/$filename

if (($size_curr > 243))
then
size_curr=240
fi
#size_curr=$(expr $size_curr - 4)
fslroi $DIR/old/$filename $f 0 -1 0 -1 0 -1 4 $size_curr
done

FILES=$DIR/*retino*
for f in $FILES
do
size_curr=$(fslval $f dim4)
size_curr=$(expr $size_curr - $(expr $size_curr % 4))

filename=$(echo $f |rev | cut -d '/' -f1 | rev)
echo selecting ROI for $f...
mv $f $DIR/old/$filename
if (($size_curr > 131))
then
size_curr=128
fi
#size_curr=$(expr $size_curr - 4)
fslroi $DIR/old/$filename $f 0 -1 0 -1 0 -1 0 $size_curr
done

echo done.
