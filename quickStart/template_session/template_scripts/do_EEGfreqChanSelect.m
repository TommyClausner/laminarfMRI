%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions'])

%%
%% avg over blocks
Selprefix='TF';

blocks=[1, 2, 3, 4];
filters={'BP2_32','BP2_32beta','BP30_100'};

ROIs={'centV1_lhV1','centV1_rhV1'};

clean_prefixes={'TCsel', 'BP', 'TL', 'Beamf', 'VirtCh', 'TF'};

if ~exist('clean_EEG_folder','var')
    clean_EEG_folder=0;
end
timeWinMax = [0.1 1.39]; % in s

freqROIs={'alpha','beta', 'gamma'};

ROIalpha = [8,12];
ROIbeta  = [22.5,27.5];
ROIgamma = [50,70];

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
    'sortAll',[],...
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
            BLwin = [-0.3 -0.2];
            
        case 'BP2_32'
            dataTemplate.freqROI=freqROIs{1};
            freqInt=ROIalpha;  
            sorting='ascend'; 
            BLwin = [-0.3 -0.2];
        case 'BP2_32beta'
            dataTemplate.freqROI=freqROIs{2};
             freqInt=ROIbeta; 
            sorting='ascend'; 
            BLwin = [-0.3 -0.2];
    end
    dataTemplate.baselineWin=BLwin;
    for nameROI=ROIs
        
        avg_tmp=[];
        VC=[];
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
            
            avg_tmp=cat(ndims(dataTFR.powspctrm)+1,avg_tmp, dataTFR.powspctrm);
            VC=cat(ndims(virtChannels)+1,VC, virtChannels);
            
            dataTemplate.beamformerWeights=cat(2,dataTemplate.beamformerWeights,{dataSrc.avg});
            
        end
        
        avg=permute(log10(abs(avg_tmp)), [2,3,4,1,5]);
        
        % avg over trials and blocks
        dataTFR.cfg=[];
        dataTFR.powspctrm=squeeze(mean(mean(avg,ndims(avg)),ndims(avg)-1));
        dataTFR.dimord='chan_freq_time';
        virtChannelsAvg=mean(mean(VC,ndims(VC)),ndims(VC)-1);
        
        name_=split(nameROI{1},'_');
        dataTemplate.ROI=name_{2};
        dataTemplate.pos=ROIpos;
        dataTemplate.freqROIfreq=freqInt;
        

        indsFreq=dataTFR.freq>=freqInt(1) & dataTFR.freq <= freqInt(2);
        
        linecoordsY=[freqInt;freqInt];
        
        linecoordsX=[timeWinMax;timeWinMax];
        
        linecoordsY=[reshape(linecoordsY,2,[]),freqInt'];
        
        linecoordsX=[linecoordsX',[timeWinMax(1);timeWinMax(1)]];
        
        % relative change in frequency:
        % only average over time:
        % devide each timepoint of the data for each channel, block,
        % frequency separately by the average of the corresponding
        % timepoints of the baseline window
        indsTime=dataTFR.time>=timeWinMax(1) & dataTFR.time <= timeWinMax(2);
        indsBL=dataTFR.time>=BLwin(1) & dataTFR.time <= BLwin(2);
        baseline = nanmean(reshape(avg(:,indsFreq,indsBL,:,:),size(avg,1),sum(indsFreq),[],size(avg,4),size(avg,5)),3);
        tmp_avg=nanmean(reshape(avg(:,indsFreq,indsTime,:,:)-repmat(baseline,1,1,sum(indsTime),1,1),size(avg,1),[]),2);
        
        % relative change
        [~,I]=sort(tmp_avg, sorting);
        
        for bestNumchan = [1,10,100] % 0 = 'all'
            
            if bestNumchan==0
                chanSel=I;
            else
                chanSel=I(1:bestNumchan);
            end
            
            dataTFR.time = dataTFR.time(dataTFR.time <= timeWinMax(2));
            dataTFR.powspctrm = dataTFR.powspctrm(:,:,dataTFR.time <= timeWinMax(2));
            
            dataTemplate.results.trial=VC(chanSel,:,:,:);
            dataTemplate.results.label=chanSel;
            dataTemplate.results.sortord=sorting;
            dataTemplate.results.sortAll=I;
            
            cfg = [];
            cfg.baseline     = BLwin;
            cfg.colormap     = 'jet';
            cfg.baselinetype = 'absolute';
            cfg.channel      = chanSel;
            cfg.interactive  = 'no';
            cfg.zlim         = 'maxabs';
            cfg.xlim         = [BLwin(1) timeWinMax(2)];
            tfig
            set(gcf,'Position',[0 0 1 0.25])
            subplot(221)
            ft_singleplotTFR(cfg, dataTFR);
            xlabel('time (ms)')
            ylabel('frequency (Hz)')
            hold on
            line([0,0],ylim,'Color','w','Linewidth',2);
            line(linecoordsX,linecoordsY,'Color','w','Linewidth',2,'Linestyle',':');
            hold off
            title('absolute')
            subplot(222)
            cfg.baselinetype = 'relchange';
            ft_singleplotTFR(cfg, dataTFR);
            xlabel('time (ms)')
            ylabel('frequency (Hz)')
            hold on
            line([0,0],ylim,'Color','w','Linewidth',2);
            line(linecoordsX,linecoordsY,'Color','w','Linewidth',2,'Linestyle',':');
            hold off
            title(['relative to baseline (' num2str(cfg.baseline(1)) ' ' num2str(cfg.baseline(2)) ')'])
            
            subplot(2,2,[3,4])
            plot(linspace(-500,1600,size(virtChannelsAvg,2)),squeeze(mean(mean(virtChannelsAvg(chanSel,:,:),3),1)))
            xlim([-500 1600])
            xlabel('time (ms)')
            ylabel('mysterious unit')
            title(['tseries top ' num2str(bestNumchan) ' voxel'])
            line([0,0],ylim)
            
            tmp=split(nameROI{1},'_');
            
            suptitle(['average over top ' num2str(bestNumchan) ' dipole pos (t = [' num2str(cfg.xlim(1)) ' ' num2str(cfg.xlim(2)) ']; t_{selWin} = [' num2str(timeWinMax(1)) ' ' num2str(timeWinMax(2)) '])'])
            
            saveas(gcf,[mainpath filesep '..' filesep 'C_miscResults' filesep tmp{2} '_' filter{1} '_Bavg_bestNumChan_' num2str(bestNumchan) '.jpg'])
            close all
        end
        dataTFR.powspctrm=avg_tmp(:,chanSel,:,:,:);
        dataTFR.dimord='rpt_chan_freq_time_block';
        dataTemplate.ft_freqanalysis=dataTFR;
        VirtChanData=cat(1,VirtChanData,dataTemplate);
    end
end

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'EEGprocessed.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'EEGprocessed.mat'],'VirtChanData','-v7.3')
disp('done.')


if clean_EEG_folder
    disp('cleaning old files...')
    for deleteThis = clean_prefixes
        delete([mainpath filesep '..' filesep '6_EEG' filesep deleteThis{1} '*'])
    end
    disp('done.')
end

%%
exit
