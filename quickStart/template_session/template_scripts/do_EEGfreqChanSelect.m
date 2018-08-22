%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions'])

%% avg over blocks
Selprefix='TF';

blocks=[1, 2, 3, 4];
filters={'BP30_100','BP2_32','BP2_32beta'};

ROIs={'centV1_lhV1','centV1_rhV1'};

clean_prefixes={'TCsel', 'BP', 'TL', 'Beamf', 'VirtCh', 'TF'};

if ~exist('clean_EEG_folder','var')
    clean_EEG_folder=0;
end
timeWinMax = [0.1 1.4]; % in s

freqROIs={'alpha','beta', 'gamma'};

ROIalpha = [8,12];
ROIbeta  = [22.5,27.5];
ROIgamma = [50,70];

NumChannelsToSelect = [1]; % 0 = 'all'

dataTemplate = struct(...
    'ROI',[],...
    'pos',[],...
    'freqROI','',...
    'freqROIfreq',[],...
    'filterBand',[],...
    'baselineWin',[],...
    'tROI',timeWinMax,...
    'ft_freqanalysis',{struct()},...
    'results',...
    {struct(...
    'trial',[],...
    'dimord','chan_time_rpt_block',...
    'label',[],...
    'sortord',[])},...
    'beamformerWeights',[]);

VirtChanData=[];

for filter=filters
    
    filtername=split(filter{1},'beta');
    
    tmp_band=split(filter{1},'_');
    dataTemplate.filterBand=[str2double(tmp_band{1}(3:end)),str2double(tmp_band{2})];
    
    switch filter{1}
        case 'BP30_100'
            dataTemplate.freqROI=freqROIs{3};
            freqInt=ROIgamma;
            sorting='descend';
            BLwin = [-0.3 -0.1];
            
        case 'BP2_32'
            dataTemplate.freqROI=freqROIs{1};
            freqInt=ROIalpha;
            sorting='ascend';
            BLwin = [-0.3 -0.1];
        case 'BP2_32beta'
            dataTemplate.freqROI=freqROIs{2};
            freqInt=ROIbeta;
            sorting='ascend';
            BLwin = [-0.3 -0.1];
    end
    
    linecoordsY=[freqInt;freqInt];
    linecoordsX=[timeWinMax;timeWinMax];
    linecoordsY=[reshape(linecoordsY,2,[]),freqInt'];
    linecoordsX=[linecoordsX',[timeWinMax(1);timeWinMax(1)]];
    
    dataTemplate.baselineWin=BLwin;
    for nameROI=ROIs
        name_=split(nameROI{1},'_');
        VC=[];
        avg_tmp=[];
        dataTemplate.beamformerWeights=[];
        chanLabels=[];
        chanPos=[];
        
        % pre-selection over blocks to save memory
        for block = blocks
            disp(num2str(block))
            
            TFRDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '*' nameROI{1} '*' filtername{1} '*' num2str(block) '.mat']);
            files=cellfun(@(x) [TFRDataFiles(1).folder filesep x],{TFRDataFiles.name},'unif',0);
            load(files{1})
            
            TFRDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep 'Beamf' '*' nameROI{1} '*' filtername{1} '*' num2str(block) '.mat']);
            files=cellfun(@(x) [TFRDataFiles(1).folder filesep x],{TFRDataFiles.name},'unif',0);
            load(files{1})
            
            VCDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep 'Virt' '*' nameROI{1} '*' filtername{1} '*' num2str(block) '.mat']);
            files=cellfun(@(x) [VCDataFiles(1).folder filesep x],{VCDataFiles.name},'unif',0);
            load(files{1})
            
            dataTemplate.beamformerWeights=cat(2,dataTemplate.beamformerWeights,{dataSrc.avg});
            data = [];
            dataTL = [];
            clearvars data dataTL
            
            raw_pow_spctrm = dataTFR.powspctrm;
            
            % avg over trials
            avg = permute(log10(abs(raw_pow_spctrm)),[2,3,4,1]);
            dataTFR.cfg=[];
            dataTFR.powspctrm=squeeze(nanmean(avg,ndims(avg)));
            dataTFR.dimord='chan_freq_time';
                        
            indsFreq=dataTFR.freq>=freqInt(1) & dataTFR.freq <= freqInt(2);
            
            % relative change in frequency:
            % only average over time:
            % devide each timepoint of the data for each channel, block,
            % frequency separately by the average of the corresponding
            % timepoints of the baseline window
            indsTime=dataTFR.time>=timeWinMax(1) & dataTFR.time <= timeWinMax(2);
            indsBL=dataTFR.time>=BLwin(1) & dataTFR.time <= BLwin(2);
            baseline = nanmean(reshape(avg(:,indsFreq,indsBL,:),size(avg,1),sum(indsFreq),[],size(avg,4)),3);
            tmp_avg=nanmean(reshape(avg(:,indsFreq,indsTime,:)-repmat(baseline,1,1,sum(indsTime),1),size(avg,1),[]),2);
            
            avg=[];
            clearvars avg
            
            % relative change
            [~,I]=sort(tmp_avg, sorting);
            
            if min(NumChannelsToSelect)==0
                chanSel_tmp=I;
            else
                chanSel_tmp=I(1:max(NumChannelsToSelect));
            end
            
            VC = cat(ndims(virtChannels)+1,virtChannels(chanSel_tmp,:,:));            
            avg_tmp = cat(ndims(raw_pow_spctrm)+1,avg_tmp,raw_pow_spctrm(:,chanSel_tmp,:,:));
            
            chanLabels = cat(2, chanLabels,chanSel_tmp);
            chanPos = cat(3, chanPos,dataSrc.pos(chanSel_tmp,:));
            
            virtChannels = [];
            raw_pow_spctrm = [];
            baseline=[];
            dataSrc = [];

            clearvars virtChannels raw_pow_spctrm baseline dataSrc
        end
        
        % avg over trials
        avg = permute(log10(abs(avg_tmp)),[2,3,4,1,5]);
        dataTFR.cfg=[];
        dataTFR.powspctrm=squeeze(nanmean(nanmean(avg,ndims(avg)),ndims(avg)-1));
        if ndims(dataTFR.powspctrm)<3          
            dataTFR.powspctrm=reshape(dataTFR.powspctrm,1,size(dataTFR.powspctrm,1),size(dataTFR.powspctrm,2));
        end
        dataTFR.dimord='chan_freq_time';

        indsFreq=dataTFR.freq>=freqInt(1) & dataTFR.freq <= freqInt(2);

        % relative change in frequency:
        % only average over time:
        % devide each timepoint of the data for each channel, block,
        % frequency separately by the average of the corresponding
        % timepoints of the baseline window
        indsTime=dataTFR.time>=timeWinMax(1) & dataTFR.time <= timeWinMax(2);
        indsBL=dataTFR.time>=BLwin(1) & dataTFR.time <= BLwin(2);
        baseline = nanmean(reshape(avg(:,indsFreq,indsBL,:,:),size(avg,1),sum(indsFreq),[],size(avg,4),size(avg,5)),3);
        tmp_avg=nanmean(reshape(avg(:,indsFreq,indsTime,:,:)-repmat(baseline,1,1,sum(indsTime),1,1),size(avg,1),[]),2);             
                
        [~,I]=sort(tmp_avg, sorting);
                
        for bestNumchan = NumChannelsToSelect
            
            if bestNumchan==0
                chanSel=I;
            else
                chanSel=I(1:bestNumchan);
            end
            
            dataTFR.time = dataTFR.time(dataTFR.time <= timeWinMax(2));
            dataTFR.powspctrm = dataTFR.powspctrm(chanSel,:,dataTFR.time <= timeWinMax(2));
            dataTFR.dimord='chan_freq_time';
            dataTFR.label=arrayfun(@num2str, chanSel, 'unif',0);
            
            dataTemplate.results.trial=VC(chanSel,:,:,:);
            dataTemplate.results.label=chanLabels;
            dataTemplate.results.sortord=sorting;
            dataTemplate.pos=chanPos;
            
            cfg = [];
            cfg.baseline     = BLwin;
            cfg.colormap     = 'jet';
            cfg.baselinetype = 'absolute';
            cfg.channel      = chanSel;
            cfg.interactive  = 'no';
            cfg.zlim         = 'maxabs';
            cfg.xlim         = [-0.3 1.6];
            tfig
            set(gcf,'Position',[0 0 1 0.25])
            ft_singleplotTFR(cfg, dataTFR);
            xlabel('time (ms)')
            ylabel('frequency (Hz)')
            hold on
            line([0,0],ylim,'Color','w','Linewidth',2);
            line(linecoordsX,linecoordsY,'Color','w','Linewidth',2,'Linestyle',':');
            hold off
            title(['average over top ' num2str(bestNumchan) ' dipole pos (t = [' num2str(cfg.xlim(1)) ' ' num2str(cfg.xlim(2)) ']; t_{selWin} = [' num2str(timeWinMax(1)) ' ' num2str(timeWinMax(2)) '])'])
            
            tmp=split(nameROI{1},'_');
                        
            if bestNumchan==1
                chanPos=round(chanPos);
               add_string = ['_xyz_' num2str(chanPos(1)) '_' num2str(chanPos(2)) '_' num2str(chanPos(3))];
            else
                add_string = ['_Bavg_bestNumChan_' num2str(bestNumchan)];
            end
            saveas(gcf,[mainpath filesep '..' filesep 'C_miscResults' filesep tmp{2} '_' filter{1} add_string '2.jpg'])
            close all
        end
        
        dataTFR.powspctrm=avg_tmp(:,chanSel,:,:,:);
        dataTFR.dimord='rpt_chan_freq_time_block';
        dataTemplate.ft_freqanalysis=dataTFR;
        VirtChanData=cat(1,VirtChanData,dataTemplate);
    end
end
%
disp(['saving data to ' mainpath filesep '..' filesep '7_results' filesep 'EEGprocessed.mat'])
save([mainpath filesep '..' filesep '7_results' filesep 'EEGprocessed2.mat'],'VirtChanData','-v7.3')
disp('done.')
%%

if clean_EEG_folder
    disp('cleaning old files...')
    for deleteThis = clean_prefixes
        delete([mainpath filesep '..' filesep '6_EEG' filesep deleteThis{1} '*'])
    end
    disp('done.')
end

%%
exit
