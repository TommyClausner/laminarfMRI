%% adapted from Rene Scheeringa (2018, DCCN)
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions'])

%% matrix order: Hemi x area x whatelse
MRI_data = [mainpath filesep '..' filesep '7_results' filesep 'MRIprocessed.mat'];
load(MRI_data)
hemis = {'lh','rh'};
ROIs = {'V1','V2','V3'};

shape_data = size(data.data);

masks=false(shape_data(1), length(hemis), length(ROIs));
layer_perc=cell(length(hemis), length(ROIs));
data_sel=cell(size(layer_perc));

for hemi=hemis
    [~,Ihemi]=ismember(hemi,hemis);
    for ROI = ROIs
        [~,Iroi]=ismember(ROI,ROIs);
        eval(['masks(:, Ihemi,Iroi) = sum(data.layerROIs.' hemi{1} '.' ROI{1} ',2)>0;']);
        eval(['layer_perc{Ihemi,Iroi} = data.layerROIs.' hemi{1} '.' ROI{1} '(masks(:,Ihemi, Iroi),:);']);
        data_sel{Ihemi,Iroi} = zscore(data.data(masks(:,Ihemi, Iroi),:,:),0,2);
    end
end

wm_sig=squeeze(mean(data.data(logical(data.maskwhite),:,:)));
gm_sig=squeeze(mean(data.data(logical(data.maskgray),:,:)));
RP_temp=squeeze(data.transvecs);

%%
num_vols=180;
vol_per_chunk = 3;
num_blocks=4;

T1_gray = zeros(num_vols,1);
T1_white = zeros(num_vols,1);

for n = 1:vol_per_chunk
    T1_gray(n:vol_per_chunk:end) = mean(mean(gm_sig(n:vol_per_chunk:end,:)));
    T1_white(n:vol_per_chunk:end) = mean(mean(wm_sig(n:vol_per_chunk:end,:)));
end

wm_sig_res = zeros(size(wm_sig));

blocks=[1:num_blocks];

for block=blocks
    bs=[T1_white ones(num_vols,1)]\ wm_sig(:,block);
    wm_sig_res(:,block)=wm_sig(:,block)-[T1_white ones(num_vols,1)]*bs;
    wm_sig_res(:,block)=wm_sig_res(:,block)-min(wm_sig_res(:,block));
    wm_sig_res(:,block)=wm_sig_res(:,block)./max(wm_sig_res(:,block));
end

%% 
sts={'beta', 'r'};

num_params = size(RP_temp,1);

realignment_params = zeros(num_params,num_vols, num_blocks);

for RP=1:num_params
    for block=1:num_blocks       
        stats_rp=regstats(RP_temp(RP,:,block),T1_white,'linear', sts);
        realignment_params(RP,:,block)=stats_rp.r+stats_rp.beta(1);
    end
end

movement_params = [];

for block=1:num_blocks
    movement_params=cat(3,movement_params, fun_make_rp2(realignment_params(:,:,block)));
end

ders1=zeros(num_vols,num_params,num_blocks);

ders1(1:vol_per_chunk:num_vols,1:num_params,:)=zscore(movement_params(1:vol_per_chunk:num_vols,13:18,:));
sel=setdiff(1:num_vols,1:vol_per_chunk:num_vols);
temp=movement_params(sel,13:18,:);
ders234(sel,:,:)=zscore(temp);

RP_all=cat(2,movement_params(:,1:12,:),ders1,ders234);

%%
EEG_reg = [mainpath filesep '..' filesep '6_EEG' filesep 'task_reg.mat'];

load(EEG_reg);
freq=0.006;
n_trls=60;
n_scans_per_trial = 3;
TR=3300;
Pause=3000;
chunksize=300;

filt=fun_make_filt_regs(freq, n_trls, n_scans_per_trial, TR, Pause, chunksize);

%% design matrices

R=[];
for block=1:num_blocks
    
    eval(['nr_task = nuisreg_conv.b' num2str(block) '.task(:,2:end);']);
    eval(['rr_task = rtreg_conv.b' num2str(block) '.task(:,2:end);']);
    wm_res = wm_sig_res(:,block);
    eval(['rr_par = rtreg_conv.b' num2str(block) '.par;']);
    
    CF=[nr_task, rr_task, wm_res, rr_par, T1_white, RP_all(:,:,block) filt.regs];
    
    eval(['task_convL = task_conv.L.b' num2str(block) '.task;']);
    eval(['task_convR = task_conv.R.b' num2str(block) '.task;']);
    R = cat(3,R, [task_convL, task_convR, CF]);
    save([mainpath filesep '..' filesep '6_EEG' filesep 'DM_regs_B' num2str(block) '.mat'], 'R')
end

%%
exit