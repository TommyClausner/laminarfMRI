#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

qsub -l walltime=24:00:00,mem=$1 -F "$DIR ${@:3}" $DIR/$2
