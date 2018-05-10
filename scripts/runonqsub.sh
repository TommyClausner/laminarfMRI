#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

qsub -l walltime=23:59:59,mem=$1 -F "$DIR ${@:3}" $DIR/$2
