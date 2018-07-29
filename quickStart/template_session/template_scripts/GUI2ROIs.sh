#!/bin/bash

### BEGIN HEADER ###

### Scriptinator ###

# General information #
# label=GUI2ROIs
# file=GUI2ROIs.sh
# useqsub=false
# shortLabel=GUI2La

### Script ###

# Input Variables and Paths #
SubjectFolder="0_freesurfer"

# Output Variables and Paths #
OutputVarName=none

# Qsub information #
jobtype=batch
walltime="24:00:00"
memory=32gb

# Misc Variables #
MiscVarName=none

### END HEADER ###

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
export SUBJECTS_DIR=$DIR/
tksurfer $SubjectFolder lh inflated -curv -overlay $DIR/4_retinotopy/lh.ang.mgh -overlay-reg $DIR/3_coregistration/bbregister.dat -fminmax 0.01 3.14
tksurfer $SubjectFolder rh inflated -curv -overlay $DIR/4_retinotopy/rh.ang.mgh -overlay-reg $DIR/3_coregistration/bbregister.dat -fminmax 0.01 3.14






