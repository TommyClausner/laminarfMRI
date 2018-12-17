%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
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
    
    for filter_tmp=FiltSel
        
        filter=possibleFilters(filter_tmp);
        
        filterNum=cellfun(@(x) strsplit(x,'BP'),strsplit(filter{1},'_'),'unif',0);

        filterNum=str2double([filterNum{1}{2},filterNum{2}]);
        
        foi=filterNum(1):1/slidW(filter_tmp):filterNum(2);
        
        for ROI_tmp=ROISel
            ROI=ROIs(ROI_tmp);
            nameROI=ROI{1};
            VirtChanDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*' nameROI '*' filter{1} '*' num2str(block) '.mat']);
            files=cellfun(@(x) [VirtChanDataFiles(1).folder filesep x],{VirtChanDataFiles.name},'unif',0);
            
            EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep 'Beamf*' nameROI '*' filter{1} '*' num2str(block) '.mat']);
            filesEEG=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
            
            for fileNum=1:size(files,2)
                
                disp(['processing block ' num2str(block) ' ' filter{1} ' ' nameROI '...'])
                file_=files(fileNum);
                fileEEG_=filesEEG(fileNum);
                load(file_{1})
                load(fileEEG_{1})
                
                dataTFR=[];
                dataTFR.label=strsplit(num2str(1:size(virtChannels,1)));
                dataTFR.trial=permute(virtChannels,[3,1,2]);
                
                % manual padding becaue fieldtrip sucks and doesn't do it
                dataTFR.trial = arrayfun(@(x) {squeeze(dataTFR.trial(x,:,:))},1:size(dataTFR.trial,1));
                dataTFR.time= arrayfun(@(x) {data.time{1}},1:length(dataTFR.trial));
                
                dataTFR.dimord='chan_time';
                dataTFR.trialinfo = data.trialinfo(1);
                
                cfg              = [];
                cfg.output       = 'pow';
                cfg.channel      = 'all';
                cfg.method       = 'mtmconvol';
                cfg.taper        = 'dpss';
                cfg.foi          = foi;
                cfg.pad          = 4;
                
                if find(cellfun(@(x) strcmp(filter{1},x), possibleFilters))==2
                    cfg.tapsmofrq  = 2.5;
                else
                    cfg.tapsmofrq    = 10;
                end
                     % analysis 2 to 30 Hz in steps of 2 Hz
                cfg.t_ftimwin    = ones(length(cfg.foi),1).*slidW(filter_tmp);   % length of time window = 0.5 sec
                cfg.toi          = -1:0.02:2;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
                cfg.keeptrials   = 'yes';
                dataTFR = ft_freqanalysis(cfg, dataTFR);
                
                saveFileName=strsplit(file_{1},'.mat');
                saveFileName=strsplit(saveFileName{1},filesep);
                saveFileName=saveFileName{end};
                
                disp('done.')
                
                disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
                save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'],'dataTFR','-v7.3')
                disp('done.')
                dataTFR=[];
                clearvars dataTFR
            end
        end
    end
end

%%
exit
