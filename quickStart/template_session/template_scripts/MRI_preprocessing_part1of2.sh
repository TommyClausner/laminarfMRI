#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo MRI preprocessing part 1... estimated duration 6h
echo doing realignment...
sh runonqsub.sh 32gb do_realignment.sh
echo done.
echo estimate field distortion...
sh runonqsub.sh 32gb do_distcorr.sh
echo done.
echo correct field distortion...
sh runonqsub.sh 64gb do_applysimpledistcorr.sh
echo done.
echo prepare coregistration...
sh runonqsub.sh 16gb do_preparecoregistration.sh
sh do_correctavgdiff.sh
echo done.
echo "CHECK RESULT $DIR/../3_coregistration/MCTemplateThrCont.nii AND CONTINUE WITH PART 2"

