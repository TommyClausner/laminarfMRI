#!/bin/bash
if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/../2_coregistration
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../2_coregistration"

fi

cd $DIR
cat $DIR/bbregister.dat | sed -n 5,8p > $DIR/bbtransmat.txt

awk '{ out=""; for(i=1;i<=NF;i++){out=out" "sprintf("%.9f", $i)}; print out}' $DIR/bbtransmat.txt > $DIR/bbtransmatconv.txt

