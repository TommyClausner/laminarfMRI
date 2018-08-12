%% adapted from Rene Scheeringa (2018, DCCN)
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end

addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'OpenFmriAnalysis'])
tvm_installOpenFmriAnalysisToolbox

%%
load([mainpath filesep '..' filesep '7_results' filesep 'MRIprocessed.mat'])

%act_nii=load_untouch_nii('/project/3018037.01/Experiment3.2_ERC/tommys_folder/transfer_to_Rene/distCor_motCor_task/P31/models/no_smth/Pos_P5.nii');
act_nii=load_untouch_nii([mainpath filesep '..' filesep '7_results' filesep 'spmT_0001.nii']);
LR_nii=load_untouch_nii([mainpath filesep '..' filesep '7_results' filesep 'spmT_0004.nii']);

L_nii=load_untouch_nii([mainpath filesep '..' filesep '7_results' filesep 'spmT_0005.nii']);
R_nii=load_untouch_nii([mainpath filesep '..' filesep '7_results' filesep 'spmT_0006.nii']);

msk_posLR=((L_nii.img(:)>1.64)+(R_nii.img(:)>1.64))>0;
msk_LR=abs(LR_nii.img(:))>1.64;
t_pos= act_nii.img(:);

%% hemi x ROI x whatelse
hemis = {'lh','rh'};
ROIs = {'V1','V2','V3'};

shape_data = size(data.data);

masks=false(shape_data(1), length(hemis), length(ROIs));
layer_perc=cell(length(hemis), length(ROIs));
data_sel=cell(size(layer_perc));
cw_perc=cell(size(layer_perc));

for hemi=hemis
    [~,Ihemi]=ismember(hemi,hemis);
    for ROI = ROIs
        [~,Iroi]=ismember(ROI,ROIs);
        eval(['masks(:, Ihemi,Iroi) = sum(data.layerROIs.' hemi{1} '.' ROI{1} ',2)>0;']);
        eval(['layer_perc{Ihemi,Iroi} = data.layerROIs.' hemi{1} '.' ROI{1} '(masks(:,Ihemi, Iroi),:);']);
        data_sel{Ihemi,Iroi} = zscore(data.data(masks(:,Ihemi, Iroi),:,:),0,2);
        cw_perc{Ihemi,Iroi} = data.CSFwhite(masks(:,Ihemi, Iroi),:);
    end
end

wm_sig=squeeze(mean(data.data(logical(data.maskwhite),:,:)));
gm_sig=squeeze(mean(data.data(logical(data.maskgray),:,:)));
RP_temp=squeeze(data.transvecs);

clear data

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

T1_gray=T1_gray-min(T1_gray);
T1_gray=T1_gray./max(T1_gray);

T1_white=T1_white-min(T1_white);
T1_white=T1_white./max(T1_white);

wm_sig_res = zeros(size(wm_sig));

blocks=[1:num_blocks];

for block=blocks
    bs=[T1_white ones(num_vols,1)]\ wm_sig(:,block);
    wm_sig_res(:,block)=wm_sig(:,block)-[T1_white ones(num_vols,1)]*bs;
    wm_sig_res(:,block)=wm_sig_res(:,block)-min(wm_sig_res(:,block));
    wm_sig_res(:,block)=wm_sig_res(:,block)./max(wm_sig_res(:,block));
end

save([mainpath filesep '..' filesep '7_results' filesep 'compregs.mat'], 'T1_gray','T1_white','wm_sig_res');

%% RP
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

save([mainpath filesep '..' filesep '7_results' filesep 'RP.mat'],'RP_all');


%%
load([mainpath filesep '..' filesep '6_EEG' filesep 'convolved_eeg_task_regressors.mat']); 

freq=0.006;
n_trls=60;
n_scans_per_trial = 3;
TR=3300;
Pause=3000;
chunksize=300;
filt=fun_make_filt_regs(freq, n_trls, n_scans_per_trial, TR, Pause, chunksize);


%% design matrices
CF.blok1=[nuisreg_conv.b1.task(:,2:end) rtreg_conv.b1.task(:,1) rtreg_conv.b1.par T1_white' squeeze(RP_all(:,:,1)) filt.regs ones(240,1)];
CF.blok2=[nuisreg_conv.b2.task(:,2:end) rtreg_conv.b2.task(:,1) rtreg_conv.b2.par T1_white' squeeze(RP_all(:,:,2)) filt.regs ones(240,1)];
CF.blok3=[nuisreg_conv.b3.task(:,2:end) rtreg_conv.b3.task(:,1) rtreg_conv.b3.par T1_white' squeeze(RP_all(:,:,3)) filt.regs ones(240,1)];
CF.blok4=[nuisreg_conv.b4.task(:,2:end) rtreg_conv.b4.task(:,1) rtreg_conv.b4.par T1_white' squeeze(RP_all(:,:,4)) filt.regs ones(240,1)];%wm_sig_res(:,4) 

%% temporal regression

Templates.lh.V1=make_feature_template(data_sel.lh.V1,layer_perc.lh.V1,cw_perc.lh.V1,CF,task_conv);
Templates.lh.V2=make_feature_template(data_sel.lh.V2,layer_perc.lh.V2,cw_perc.lh.V2,CF,task_conv);
Templates.lh.V3=make_feature_template(data_sel.lh.V3,layer_perc.lh.V3,cw_perc.lh.V3,CF,task_conv);

Templates.rh.V1=make_feature_template(data_sel.rh.V1,layer_perc.rh.V1,cw_perc.rh.V1,CF,task_conv);
Templates.rh.V2=make_feature_template(data_sel.rh.V2,layer_perc.rh.V2,cw_perc.rh.V2,CF,task_conv);
Templates.rh.V3=make_feature_template(data_sel.rh.V3,layer_perc.rh.V3,cw_perc.rh.V3,CF,task_conv);
   
%%

centr=1; %centred or not centred
templ=1; %template type 1:block, 2:other blokcs (3); 3: all blocks (4)

hemis={'lh', 'rh'};
ROIs={'V1', 'V2', 'v3'};

for hemi=hemis
    for ROI = ROIs
        eval([ 'roi = data_sel.' hemi{1} '.' ROI{1} ';']);
        eval(['feat_sigs.' hemi{1} '.' ROI{1} '=fun_template_fit (centr,templ,' ROI{1} ',' hemi{1} ', Templates, roi,CF);']);
    end
end

%%
save([mainpath filesep '..' filesep '7_results' filesep 'feat_sigs_centr' num2str(centr) '_templ' num2str(templ) '.mat'],'feat_sigs');

%% 
exit

