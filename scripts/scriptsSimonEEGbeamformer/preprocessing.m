data_name              = 'Data/P31_B1.eeg';        % define the data path and its name
 
% Read events
cfg                    = [];                    
cfg.trialdef.prestim   = 0.5;                   % in seconds
cfg.trialdef.poststim  = 1.6;                   % in seconds
cfg.trialdef.eventtype = 'Stimulus';            % get a list of the available types
cfg.trialdef.eventvalue = {'S  1','S  2','S 11','S 12','S 13','S 14','S 21','S 22','S 23','S 24'};
cfg.dataset            = data_name;             % set the name of the dataset
cfg_tr_def             = ft_definetrial(cfg);   % read the list of the specific stimulus 
 
cfg                    = [];
cfg.dataset            = data_name;      
cfg.channel            = 'eeg';             % define channel type
data                   = ft_preprocessing(cfg); % read raw data 
 
% segment data according to the trial definition
data                   = ft_redefinetrial(cfg_tr_def, data);

%%
cfg                = [];                
cfg.hpfilter       = 'yes';        % enable high-pass filtering
cfg.lpfilter       = 'yes';        % enable low-pass filtering
cfg.hpfreq         = 40;           % set up the frequency for high-pass filter
cfg.lpfreq         = 80;          % set up the frequency for low-pass filter
cfg.dftfilter      = 'yes';        % enable notch filtering to eliminate power line noise
cfg.dftfreq        = [50 100 150]; % set up the frequencies for notch filtering
cfg.baselinewindow = [-0.5 -0.1];    % define the baseline window
data               = ft_preprocessing(cfg,data);

%%
cfg        = [];
cfg.metric = 'zvalue';  % use by default zvalue method
cfg.method = 'summary'; % use by default summary method
data       = ft_rejectvisual(cfg,data);

%%
cfg                   = [];
cfg.preproc.demean    = 'yes';    % enable demean to remove mean value from each single trial
cfg.covariance        = 'yes';    % calculate covariance matrix of the data
cfg.trials = (data.trialinfo==1);
cfg.covariancewindow  = [-0.5 -0.1]; % calculate the covariance matrix for a specific time window
EEG_avg_1               = ft_timelockanalysis(cfg, data);

cfg                   = [];
cfg.preproc.demean    = 'yes';    % enable demean to remove mean value from each single trial
cfg.covariance        = 'yes';    % calculate covariance matrix of the data
cfg.trials = (data.trialinfo==2);
cfg.covariancewindow  = [-0.5 -0.1]; % calculate the covariance matrix for a specific time window
EEG_avg_2               = ft_timelockanalysis(cfg, data);

%%
cfg               = [];
cfg.reref         = 'yes';
cfg.refchannel    = 'all';
cfg.refmethod     = 'avg';
EEG_avg_1           = ft_preprocessing(cfg,EEG_avg_1);
EEG_avg_2           = ft_preprocessing(cfg,EEG_avg_2);

%%
% SENS LABEL HAVE TO BE CORRECT
cfg              = []; 
cfg.method       = 'lcmv';
cfg.grid         = sourcemodel; 
cfg.headmodel    = headmodel_prep;
cfg.elec         = sens_prep;
cfg.normalize   = 'yes';
cfg.lcmv.projectnoise = 'yes';
cfg.lcmv.lambda       = 0;

sourcePost_nocon = ft_sourceanalysis(cfg, EEG_avg_1);

%%
cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'avg.pow';
sourceDiffInt  = ft_sourceinterpolate(cfg, sourcePost_nocon , mri);

cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'avg.pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [0.0 1.2];
cfg.opacitylim    = [0.0 1.2]; 
cfg.opacitymap    = 'rampup';  
ft_sourceplot(cfg, sourceDiffInt);

