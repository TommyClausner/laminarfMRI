#!/bin/bash

#checks for essential files that are needed for the analysis

missingcounter=0

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/..
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

fi

if [ ! -f $DIR/A_helperfiles/acquisition_parameters.txt ]; then
    echo "MISS acquisition_parameters.txt"
    missingcounter=$(($missingcounter+1))
else
    echo "FOUND acquisition_parameters.txt"
fi

if [ ! -f $DIR/A_helperfiles/b02b0.cnf ]; then
    echo "MISS b02b0.cnf"
    missingcounter=$(($missingcounter+1))
else
    echo "FOUND b02b0.cnf"
fi

if [ ! -f $DIR/A_helperfiles/RetStim.mat ]; then
    echo "RetStim.mat"
    missingcounter=$(($missingcounter+1))
else
    echo "FOUND RetStim.mat"
fi


echo $missingcounter files are missing
