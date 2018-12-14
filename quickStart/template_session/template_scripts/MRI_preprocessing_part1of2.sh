#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo MRI preprocessing part 1... estimated duration 6h
PIDqsub=$(sh runonqsub.sh 32gb do_preparefunctionals.sh)
sh waitForQsubPID.sh $PIDqsub
echo doing realignment...
PIDqsub=$(sh runonqsub.sh 32gb do_realignment.sh)
sh waitForQsubPID.sh $PIDqsub
echo done.
echo estimate field distortion...
PIDqsub=$(sh runonqsub.sh 32gb do_distcorr.sh)
sh waitForQsubPID.sh $PIDqsub
echo done.
echo correct field distortion...
PIDqsub=$(sh runonqsub.sh 64gb do_applysimpledistcorr.sh)
sh waitForQsubPID.sh $PIDqsub
echo done.
echo prepare coregistration...
PIDqsub=$(sh runonqsub.sh 12:00:00 16gb do_preparecoregistration.sh)
sh waitForQsubPID.sh $PIDqsub
sh do_correctavgdiff.sh
echo done.
echo "CHECK RESULT $DIR/../3_coregistration/MCTemplateThrCont.nii AND CONTINUE WITH PART 2"

