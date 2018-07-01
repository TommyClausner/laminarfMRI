%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions'])

%%

Addprefix='TF_';

Selprefix='VirtCh';

ROIs={'centV1_lhV1','centV1_rhV1'};

slidW=[0.4, 0.8 ];

if ~exist('BlockSel','var')
    BlockSel=[1,2,3,4];
end

if ~exist('FiltSel','var')
    FiltSel=[1,2];
end

if ~exist('ROISel','var')
    ROISel=[1,2];
end

possibleFilters={'BP30_100','BP2_32'};

for block=BlockSel
    counter=0;
    for filter_tmp=FiltSel
        filter=possibleFilters(filter_tmp);
        
        filterNum=cellfun(@(x) strsplit(x,'BP'),strsplit(filter{1},'_'),'unif',0);
        counter=counter+1;
        filterNum=str2double([filterNum{1}{2},filterNum{2}]);
        
        foi=filterNum(1):1/slidW(counter):filterNum(2);
        
        for ROI_tmp=ROISel
            ROI=ROIs(ROI_tmp);
            nameROI=ROI{1};
            VirtChanDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*' nameROI '*' filter{1} '*' num2str(block) '.mat']);
            files=cellfun(@(x) [VirtChanDataFiles(1).folder filesep x],{VirtChanDataFiles.name},'unif',0);
            
            EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep 'Beamf*' nameROI '*' filter{1} '*' num2str(block) '.mat']);
            filesEEG=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
            
            for fileNum=1:size(files,2)
                
                file_=files(fileNum);
                fileEEG_=filesEEG(fileNum);
                load(file_{1})
                load(fileEEG_{1})
                
                data4TFA=[];
                data4TFA.label=strsplit(num2str(1:size(virtChannels,1)));
                data4TFA.trial=permute(virtChannels,[3,1,2]);
                data4TFA.time=data.time{1};
                data4TFA.dimord='rpt_chan_time';
                
                cfg              = [];
                cfg.output       = 'pow';
                cfg.channel      = 'all';
                cfg.method       = 'mtmconvol';
                cfg.taper        = 'dpss';
                cfg.foi          = foi;
                cfg.pad          = 3.2;
                cfg.tapsmofrq    = 10;     % analysis 2 to 30 Hz in steps of 2 Hz
                cfg.t_ftimwin    = ones(length(cfg.foi),1).*slidW(counter);   % length of time window = 0.5 sec
                cfg.toi          = -1:0.01:2;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
                cfg.keeptrials   = 'yes';
                dataTFR = ft_freqanalysis(cfg, data4TFA);
                
                saveFileName=strsplit(file_{1},'.mat');
                saveFileName=strsplit(saveFileName{1},filesep);
                saveFileName=saveFileName{end};
                
                disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
                save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'],'dataTFR','-v7.3')
                disp('done.')
                
            end
        end
    end
end

%%
exit
