%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
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

possibleFilters={'BP40_80','BP8_32'};
prefix='VirtCh_';
Selprefix='Beamf_centV1';

for block=BlockSel
    
    for filt = FiltSel
        filter=possibleFilters{filt};
        EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*_FEM_TL_' filter '*' num2str(block) '.mat']);
        files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
        
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
            disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'])
            save([mainpath filesep '..' filesep '6_EEG' filesep prefix saveFileName '.mat'],'virtChannels','-v7.3')
            disp('done.')
        end
    end
end
%%
exit