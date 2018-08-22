%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults

%% virtual channel

if ~exist('BlockSel','var')
    BlockSel=[1,2,3,4];
end

if ~exist('FiltSel','var')
    FiltSel=[1,2];
end

possibleFilters={'BP30_100','BP2_32'};
Addprefix='VirtCh_';
Selprefix='Beamf_centV1_lh';

for block=BlockSel
    
    for filt = FiltSel
        filter=possibleFilters{filt};
        EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*_FEM_TL_' filter '*' num2str(block) '.mat']);
        files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
        disp([filter ' ' num2str(block)])
        for file_=files
            load(file_{1})
            
            virtChannels=[];
            for nonEmptyFilterInd=find(~cellfun(@isempty, dataSrc.avg.filter))'
                currentFilter=dataSrc.avg.filter{nonEmptyFilterInd};
                virtChannelsTrials=[];
                for trial=1:size(data.trial,2)
                    tmp=mean(dataSrc.avg.mom{nonEmptyFilterInd},2)'*currentFilter*squeeze(data.trial{trial}(:,:));
                    virtChannelsTrials=cat(3,virtChannelsTrials,tmp);
                end
                virtChannels=cat(1,virtChannels,virtChannelsTrials);
            end
            
            saveFileName=strsplit(file_{1},'.mat');
            saveFileName=strsplit(saveFileName{1},filesep);
            saveFileName=saveFileName{end};
            disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '.mat'])
            save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix saveFileName '3.mat'],'virtChannels','-v7.3')
            disp('done.')
        end
    end
end
%%
exit
