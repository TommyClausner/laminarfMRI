%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults


%% timelock analysis

noiseEstWin=[-0.5 -0.1];

sel_={'BP30_100','BP2_32'};

Addprefix='TL_';

for n=1:2
    Selprefix=sel_{n};
    
    EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*.mat']);
    files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
    
    for file_ = files
        load(file_{1})
        
        cfg               = [];
        cfg.reref         = 'yes';
        cfg.refchannel    = 'all';
        cfg.refmethod     = 'avg';
        data           = ft_preprocessing(cfg,data);
        
        cfg                   = [];
        cfg.covariance        = 'yes';    % calculate covariance matrix of the data
        
        cfg.covariancewindow  = noiseEstWin; % calculate the covariance matrix for a specific time window
        cfg.keeptrials = 'yes';
        dataTL                = ft_timelockanalysis(cfg, data);
        
        saveFileName=strsplit(file_{1},'.mat');
        saveFileName=strsplit(saveFileName{1},filesep);
        saveFileName=saveFileName{end};
        
        disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
        save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'],'data','dataTL','-v7.3')
        disp('done.')
    end
end
%%
exit
