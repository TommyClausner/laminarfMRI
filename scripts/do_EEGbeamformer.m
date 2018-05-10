%%
% mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts'

addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
ft_defaults


%% timelock analysis

noiseEstWin=[-0.5 -0.1];

Selprefix='BP40_80';


EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*.mat']);

conditions=[1,2,11:14,21:24];

for file_ = cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0)
    for cond=conditions
        load(file_{1})
        prefix=['TL_' num2str(cond) '_'];
        cfg                   = [];
        cfg.preproc.demean    = 'yes';    % enable demean to remove mean value from each single trial
        cfg.covariance        = 'yes';    % calculate covariance matrix of the data
        cfg.trials = (data.trialinfo==cond);
        cfg.covariancewindow  = noiseEstWin; % calculate the covariance matrix for a specific time window
        data                = ft_timelockanalysis(cfg, data);
        
        cfg               = [];
        cfg.reref         = 'yes';
        cfg.refchannel    = 'all';
        cfg.refmethod     = 'avg';
        data           = ft_preprocessing(cfg,data);
        
        
        saveFileName=strsplit(file_{1},'.mat');
        saveFileName=strsplit(saveFileName{1},filesep);
        saveFileName=saveFileName{end};
        
        disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'])
        save([mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'],'data','-v7.3')
        disp('done.')
    end
end

%% make source model
rmpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'Pipelines']))

cfg = [];
load([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'])

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

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'],'mri','mesh','mesh_surf','headmodel','sourcemodel','-v7.3')
disp('done.')

%% Beamformer

load([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'])
% SENS LABEL HAVE TO BE CORRECT

plotSource=0;
sens.label(1:numel(data.label))=data.label;
Selprefix='TL';

prefix='Beamf_';
EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*.mat']);
for file_ = cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0)
    load(file_{1})
    cfg              = [];
    cfg.method       = 'lcmv';
    cfg.grid         = sourcemodel;
    cfg.headmodel    = headmodel;
    cfg.elec         = sens;
    cfg.normalize   = 'yes';
    cfg.lcmv.projectnoise = 'yes';
    cfg.lcmv.lambda       = 0;
    
    dataSrc = ft_sourceanalysis(cfg, data);
    
    %
    cfg            = [];
    cfg.downsample = 2;
    cfg.parameter  = 'avg.pow';
    dataSrc  = ft_sourceinterpolate(cfg, dataSrc , mri);
    
    saveFileName=strsplit(file_{1},'.mat');
    saveFileName=strsplit(saveFileName{1},filesep);
    saveFileName=saveFileName{end};
    
    disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'])
    save([mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'],'data','dataSrc','-v7.3')
    disp('done.')
end

if plotSource
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'avg.pow';
    cfg.maskparameter = cfg.funparameter;
    cfg.funcolorlim   = [0.0 1.2];
    cfg.opacitylim    = [0.0 1.2];
    cfg.opacitymap    = 'rampup';
    ft_sourceplot(cfg, dataSrc);
end

%% virtual channel

plotVirtChannel=0;
Selprefix='TL';

prefix='VirtCh_';
EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*.mat']);

for file_ = cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0)
    load(file_{1})
    
    [~, maxpowindx] = max(dataSrc.avg.pow);
    
    cfg              = [];
    cfg.method       = 'lcmv';
    cfg.headmodel    = headmodel;
    cfg.grid.pos     = sourcemodel.pos(maxpowindx, :);
    cfg.grid.inside  = true;
    cfg.grid.unit    = sourcemodel.unit;
    cfg.lcmv.keepfilter = 'yes';
    source_idx       = ft_sourceanalysis(cfg, data);
    
    beamformer_ = source_idx.avg.filter{1};
    
    gam_pow_data = [];
    gam_pow_data.label = {'gam_pow_x', 'gam_pow_y', 'gam_pow_z'};
    gam_pow_data.time = dataSrc.time;
    
    for i=1:length(dataSrc.trial)
        gam_pow_data.trial{i} = beamformer_ * dataSrc.trial{i};
    end
    
    saveFileName=strsplit(file_{1},'.mat');
    saveFileName=strsplit(saveFileName{1},filesep);
    saveFileName=saveFileName{end};
    
    disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'])
    save([mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'],'data','dataSrc','gam_pow_data','-v7.3')
    disp('done.')
    
end

if plotVirtChannel
    cfg = [];
    cfg.viewmode = 'vertical';  % you can also specify 'butterfly'
    ft_databrowser(cfg, gam_pow_data);
end

%%
exit
