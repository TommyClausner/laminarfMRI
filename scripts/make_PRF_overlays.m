% mainpath=['P:' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];
cd([mainpath filesep '..' filesep '4_retinotopy'])
disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
disp('done.')

disp('loading data...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_avg_all.mat'])
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat'])
nii = load_untouch_nii(filetouse);
disp('done.')
%% Ang
ang_map=nii;
ang_=resultsall.ang./180.*pi;
ang_map.img(resultsall.options.vxs)=ang_;
save_untouch_nii(ang_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ang_map.nii']);
%% Ecc
degvisdeg=7;
ecc_map=nii;
ecc_=resultsall.ecc.*degvisdeg/size(images{1},2);

ecc_map.img(ind)=ecc_;
save_untouch_nii(ecc_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ecc_map.nii']);
%% Expt
expt_map=nii;
expt_map.img(ind)=resultsall.expt;
save_untouch_nii(expt_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'expt_map.nii']);
%% rfsize
rfsize_map=nii;
rfsize_map.img(ind)=resultsall.rfsize;
save_untouch_nii(rfsize_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'rfsize_map.nii']);
%% Xpos Ypos
degvisdeg=7;
cfactor = degvisdeg/size(images{1},2);

xpos = ecc_ .* cos(resultsall.ang./180.*pi) .* cfactor;
ypos = ecc_ .* sin(resultsall.ang./180.*pi) .* cfactor;

xpos_map=nii;
xpos_map.img(ind)=xpos;
xpos_map.img(~ind)=0;
save_untouch_nii(xpos_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'xpos_map.nii']);

ypos_map=nii;
ypos_map.img(ind)=ypos;
ypos_map.img(~ind)=0;
save_untouch_nii(ypos_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ypos_map.nii']);
%%
exit