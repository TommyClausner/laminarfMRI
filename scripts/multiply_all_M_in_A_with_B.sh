#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"

cd $DIR

matdir=$DIR$1

mkdir $matdir/matmulResults

singlemat=$DIR$2

for f in $matdir/*; do

if [ -f "$f" ]; then
filename=$(basename "$f")

$DIR/matmul.sh $f $singlemat > $matdir/matmulResults/$filename
fi

done
