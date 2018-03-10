#!/bin/bash

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/..
FREESURFER_HOME=/opt/freesurfer/5.3
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export PATH=$FREESURFER_HOME/bin:$PATH
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltktixblt/lib/:$LD_LIBRARY_PATH
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

fi

cd $DIR

unameOut='$(uname -s)'

case '${unameOut}' in
	Linux*)		machine=Linux;;
	Darwin*)	machine=Mac
esac

if [ '${machine}' == 'Mac' ]
then

echo setting freesurfer up for mac ...
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

else

echo setting freesurfer up for linux...

FREESURFER_HOME=/opt/freesurfer/5.3
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export PATH=$FREESURFER_HOME/bin:$PATH
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltktixblt/lib/:$LD_LIBRARY_PATH

fi

export SUBJECTS_DIR=$DIR

rm -r $DIR/0_freesurfer/*
recon-all -i $DIR/niftis/t1/* -subjid 0_freesurfer -all

