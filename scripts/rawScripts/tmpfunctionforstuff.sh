#!/bin/bash

if [[ $(hostname -s) == *"dccn"* ]]
then
DIR=$1/..
FREESURFER_HOME=/opt/freesurfer/5.3
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export PATH=$FREESURFER_HOME/bin:$PATH
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltkt$
else
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

fi

cd $DIR

unameOut='$(uname -s)'

case '${unameOut}' in
        Linux*)         machine=Linux;;
        Darwin*)        machine=Mac
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
LD_LIBRARY_PATH=$FREESURFER_HOME/lib/gsl/lib/:$FREESURFER_HOME/lib/tcltkt$

fi

export SUBJECTS_DIR=$DIR

### write stuff you wanna test below ###
# check out mri_vol2surface or so

tksurfer 0_freesurfer lh inflated -overlay $DIR/4_retinotopy/R2_map.nii -overlay-reg $DIR/2_coregistration/bbregister.dat
