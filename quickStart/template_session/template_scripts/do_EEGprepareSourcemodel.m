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
filetouse=[mainpath filesep '..' filesep 'rawData' filesep 'electrodes' filesep 'photogrammetry' filesep 'electrodes.mat'];

% if janus3D was used the below can be executed, saving manual registration
% of EEG electrodes
if ~exist([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'file')==2 &&...
        exist(filetouse,'file')==2
    sens=tc_janus3D2sens(filetouse,1:63);

    disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
    save([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'sens','-v7.3')
    disp('done.')
elseif ~exist([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'file')==2 &&...
       ~exist(filetouse,'file')==2
   error('neither sens.mat nor electrodes.mat found')
   exit
end

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