%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults

%% make source model
if ~exist('conductModel','var')
    conductModel='FEM';
end
cfg = [];
load([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' conductModel '.mat']);

chansel=1:63;

sens.chanpos=sens.chanpos(chansel,:);
sens.chantype=sens.chantype(chansel,:);
sens.chanunit=sens.chanunit(chansel,:);
sens.elecpos=sens.elecpos(chansel,:);
sens.label=sens.label(chansel,:);
sens.tra=sens.tra(chansel,:);
sens.tra=sens.tra(:,chansel);

[headmodel,sens] = ft_prepare_vol_sens(headmodel,sens);

pathname = [mainpath filesep '..' filesep];
subjname = '0_freesurfer';
datapath = fullfile(pathname,subjname,[filesep 'workbench']);
filename = fullfile(datapath,[subjname,'.L.midthickness.32k_fs_LR.surf.gii']);
sourcemodel = ft_read_headshape({filename, strrep(filename, '.L.', '.R.')});

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' headmodelType '.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' conductModel '.mat'],'mri','mesh','headmodel','sourcemodel','-v7.3')
save([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'sens')
disp('done.')

%%
exit