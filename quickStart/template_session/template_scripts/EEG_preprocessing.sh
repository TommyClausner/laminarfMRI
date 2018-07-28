#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo Process EEG data... estimated duration 20-24h
echo EEG preprocessing...
sh  do_EEGpreprocessing.sh
echo done.
echo EEG timelock analysis...
sh  do_EEGtimelock.sh
echo done.
echo prepare headmodel...
sh  do_EEGprepareHeadmodel.sh
echo done.
# interrupt here for manual EEG channel registration if necessary
echo prepare sourcemodel...
sh  do_EEGprepareSourcemodel.sh
echo done.
echo compute beamformer weights...
sh  do_EEGsplitBeamformer.sh
echo done.
echo compute virtual channels
sh  do_EEGsplitVirtualChannel.sh
echo done.
echo time frequency analysis on virtual channels...
sh  do_EEGsplitFreqOnVirtChan.sh
echo done.
echo pick best channels...
sh  do_EEGfreqChanSelect.sh
echo done.
