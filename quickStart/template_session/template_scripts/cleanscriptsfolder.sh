#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir $DIR/qsuboutput
mv $DIR/*.e* $DIR/qsuboutput/
mv $DIR/*.o* $DIR/qsuboutput/

