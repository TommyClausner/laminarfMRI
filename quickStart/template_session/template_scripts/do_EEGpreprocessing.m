%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions'])
ft_defaults

%% convert raw data to MATLAB and select trials and EEG channels

EEGDataFiles=dir([mainpath filesep '..' filesep 'rawData' filesep 'eegfiles' filesep '*.eeg']);
files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
TrialPreStim=0.5;
TrialPostStim=1.6;
%TriggerValues={'S  1','S  2','S 11','S 12','S 13','S 14','S 21','S 22','S 23','S 24'};
TriggerValues={'S  1','S  2'};

TriggerType='Stimulus';

Addprefix='TCsel_';

if ~exist('RejectTrials','var')
   RejectTrials=0; 
end

if RejectTrials
        
        filetouse=dir([mainpath filesep '..' filesep 'rawData' filesep 'eyetrackerfiles' filesep '*.asc']);
        filetouse=[filetouse(1).folder filesep filetouse(1).name];
        [~,fullData] = tc_EyeChecker(filetouse);
        
        blockinds=ones(size(fullData.BlinkTrialsTable,1)/size(files,2),size(files,2))*diag(1:size(files,2));
        blockinds=blockinds(:);
        counter=0;
end

for file_ = files
       
    % Read events
    cfg                    = [];
    cfg.trialdef.prestim   = TrialPreStim;                   % in seconds
    cfg.trialdef.poststim  = TrialPostStim;                   % in seconds
    cfg.trialdef.eventtype = TriggerType;            % get a list of the available types
    cfg.trialdef.eventvalue = TriggerValues;
    cfg.dataset            = file_{1};             % set the name of the dataset
    cfg_tr_def             = ft_definetrial(cfg);   % read the list of the specific stimulus
    
    cfg                    = [];
    cfg.dataset            = file_{1};
    cfg.channel            = 'eeg';             % define channel type
    
    data                   = ft_preprocessing(cfg); % read raw data

    if RejectTrials     
        counter=counter+1;
        cfg = [];
        cfg.trials = fullData.BlinkTrialsTable(blockinds==counter,5);
        data = ft_selectdata(cfg, data);
    end
    
    % segment data according to the trial definition
    
    saveFileName=strsplit(file_{1},'.eeg');
    saveFileName=strsplit(saveFileName{1},filesep);
    saveFileName=saveFileName{end};
    
    data                   = ft_redefinetrial(cfg_tr_def, data);
    
    cfg= [];
    cfg.demean = 'yes';
    cfg.resamplefs = 1024;
    data = ft_resampledata(cfg, data);
    
    disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
    save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'],'data','-v7.3')
    disp('done.')
end

%% bandpass filter

Selprefix='TCsel';

filters2use=[30,100;2,32];
for n=1:2
    filterPassBand=filters2use(n,:);
    timeBaseline=[-0.5 -0.1];
    
    
    Addprefix=['BP' num2str(filterPassBand(1)) '_' num2str(filterPassBand(2)) '_'];
    
    EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*.mat']);
    
    for file_ = cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0)
        load(file_{1})
        cfg                = [];
        cfg.hpfilter       = 'yes';        % enable high-pass filtering
        cfg.lpfilter       = 'yes';        % enable low-pass filtering
        cfg.hpfreq         = filterPassBand(1);           % set up the frequency for high-pass filter
        cfg.lpfreq         = filterPassBand(2);          % set up the frequency for low-pass filter
        cfg.dftfilter      = 'yes';        % enable notch filtering to eliminate power line noise
        cfg.dftfreq        = [50 100 150]; % set up the frequencies for notch filtering
        cfg.baselinewindow = timeBaseline;    % define the baseline window
        data               = ft_preprocessing(cfg,data);
        
        saveFileName=strsplit(file_{1},'.mat');
        saveFileName=strsplit(saveFileName{1},filesep);
        saveFileName=saveFileName{end};
        
        disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
        save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'],'data','-v7.3')
        disp('done.')
    end
end
%% visual inspection and trial rejection

VisInspection=0;


if VisInspection
    Selprefix='BP30_100';
    Addprefix='';
    EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*.mat']);
    for file_ = cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0)
        load(file_{1})
        cfg        = [];
        cfg.metric = 'zvalue';  % use by default zvalue method
        cfg.method = 'summary'; % use by default summary method
        data       = ft_rejectvisual(cfg,data);
        
        saveFileName=strsplit(file_{1},'.mat');
        saveFileName=strsplit(saveFileName{1},filesep);
        saveFileName=saveFileName{end};
        
        disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
        save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'],'data','-v7.3')
        disp('done.')
    end
end

%%
exit
