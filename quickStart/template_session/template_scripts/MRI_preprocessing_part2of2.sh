#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo MRI preprocessing part 2... estimated duration 6-10h
echo perform coregistration...
sh do_coregistration.sh
echo done.
echo obtain masks and labels...
sh runonqsub.sh 16gb do_makemasksandlabels.sh
sh waitForQsubPID.sh $(qstat | awk -F' ' '{print $1}' | tail -1)
echo done.
echo interpolate retinotopy scans...
sh do_tseriesinterpolation.sh
echo done.
echo perform pRF mapping...
sh do_split_analyzePRF.sh
sh combine_split_PRF_results.sh
sh make_PRF_overlays.sh
sh runonqsub.sh 16gb makeOverlays.sh
sh waitForQsubPID.sh $(qstat | awk -F' ' '{print $1}' | tail -1)
echo done.
if [ ! -f $DIR/../0 _freesurfer/mri/orig.mgz ]
then
    cp ../0 _freesurfer/mri/orig_nu.mgz ../0 _freesurfer/mri/orig.mgz
fi
echo "DO MANUAL VISUAL ROI SELECTION USING $DIR/GUI2ROIs.sh"
