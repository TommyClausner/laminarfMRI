#!/bin/bash

### do not forget to adjust operating folder ###

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

fi

cd $DIR

### write stuff you wanna test below ###

input=$1

if [ $# -eq 1 ]
then
	if [[ ${input:0:1} == '/' ]]
	then
	echo path
	else
	orient="--out_orientation $input"
	fi

elif [ $# -eq 2 ]
then
orient="--out_orientation $2"
else
orient=""
fi

