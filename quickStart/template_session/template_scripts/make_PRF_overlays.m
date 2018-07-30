%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'OpenFmriAnalysis'])
tvm_installOpenFmriAnalysisToolbox
%%

load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'params.mat']);

disp('loading data...')
filetouse=[mainpath filesep '..' filesep '3_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_all.mat'])
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat'])
nii = load_untouch_nii(filetouse);
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'images_downsampled.mat'])

disp('done.')
%% Ang
ang_map=nii;
ang_=resultsall.ang./180.*pi;
ang_map.img(resultsall.options.vxs)=ang_;
save_untouch_nii(ang_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ang_map.nii']);
%% Ecc
degvisdeg=params.radius*2;
ecc_map=nii;
ecc_=resultsall.ecc.*degvisdeg/size(images{1},2);

ecc_map.img(resultsall.options.vxs)=ecc_;
ecc_map.img(resultsall.R2<=0)=NaN;
ecc_map.img(ecc_map.img>degvisdeg & ecc_map.img<0.5)=NaN;
save_untouch_nii(ecc_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ecc_map.nii']);
%% Expt
expt_map=nii;
expt_map.img(resultsall.options.vxs)=resultsall.expt;
save_untouch_nii(expt_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'expt_map.nii']);
%% rfsize
rfsize_map=nii;
rfsize_map.img(resultsall.options.vxs)=resultsall.rfsize;
save_untouch_nii(rfsize_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'rfsize_map.nii']);
%% R2
r2_map=nii;
r2_map.img(resultsall.options.vxs)=resultsall.R2;
save_untouch_nii(r2_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'r2_map.nii']);
%% Xpos Ypos
degvisdeg=params.radius*2;
cfactor = degvisdeg/size(images{1},2);

xpos = ecc_ .* cos(resultsall.ang./180.*pi) .* cfactor;
ypos = ecc_ .* sin(resultsall.ang./180.*pi) .* cfactor;

xpos_map=nii;
xpos_map.img(resultsall.options.vxs)=xpos;
xpos_map.img(~resultsall.options.vxs)=0;
save_untouch_nii(xpos_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'xpos_map.nii']);

ypos_map=nii;
ypos_map.img(resultsall.options.vxs)=ypos;
ypos_map.img(~resultsall.options.vxs)=0;
save_untouch_nii(ypos_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ypos_map.nii']);
%%
exit
