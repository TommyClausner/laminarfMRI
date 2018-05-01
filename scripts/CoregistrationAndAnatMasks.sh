#!/bin/bash
sh /project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_fsreconQsub.sh
sh /project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_coregistration.sh
sh /project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts/do_makemasksandlabels.sh
exit 0
