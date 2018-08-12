%% adapted from Rene Scheeringa (2018, DCCN)
alpha_freqs = [7.5 12.5];
beta_freqs = [22.5 27.5];
gamma_freqs=[45 75];

timwin=[0 1.6];

low_bsln=[-0.5 -0.4];
high_bsln=[-0.5 -0.2];

chan_crit=0.25;

select_gamma_channels = 1;

sj='P31';
cond='';
stem='/project/3018037.01/Experiment3.2_ERC/Data/EEG/';
savedir_stem = '/project/3018037.01/Experiment3.2_ERC/Data/regressors/';

load([stem sj '/' sj cond '_backprojected_TFR.mat'], 'TFData*');sZ_h=size(TFData_R_high.powspctrm);
sZ_l=size(TFData_R_low.powspctrm);

%% determine frequency bins to average over for alpha, beta, gamma
alpha_bins=TFData_all_low.freq>=alpha_freqs(1) & TFData_all_low.freq<=alpha_freqs(2);
beta_bins=TFData_all_low.freq>=beta_freqs(1) & TFData_all_low.freq<=beta_freqs(2);
gamma_bins=TFData_all_high.freq>=gamma_freqs(1) & TFData_all_high.freq<=gamma_freqs(2);

%% determine time bins to slect for power regressors, and for baseline for low and high frequencies
tim_bins = TFData_all_low.time>=timwin(1) & TFData_all_low.time<=timwin(2);

bsln_low_bins = TFData_all_low.time>=low_bsln(1) & TFData_all_low.time<=low_bsln(2);
bsln_high_bins = TFData_all_high.time>=high_bsln(1) & TFData_all_high.time<=high_bsln(2);

%% compute power changes in alpha, beta and gamma bands from baseline for each channel
avg_pow_high=0.5*TFData_L_high.powspctrm+0.5*TFData_R_high.powspctrm;
avg_pow_low=0.5*TFData_L_low.powspctrm+0.5*TFData_R_low.powspctrm;

ch_pow_alpha=mean(mean(avg_pow_low(:,alpha_bins,tim_bins),3),2) - ...
             mean(mean(avg_pow_low(:,alpha_bins,bsln_low_bins),3),2);
         
ch_pow_beta=mean(mean(avg_pow_low(:,beta_bins,tim_bins),3),2) - ...
             mean(mean(avg_pow_low(:,beta_bins,bsln_low_bins),3),2);
         
ch_pow_gamma=mean(mean(avg_pow_high(:,gamma_bins,tim_bins),3),2) - ...
             mean(mean(avg_pow_high(:,gamma_bins,bsln_high_bins),3),2);

%% determine channels to average over based on alpha, beta and gamma changes from baseline
gamma_ch_sel = ch_pow_gamma >= chan_crit*max(ch_pow_gamma);

if select_gamma_channels == 1
    alpha_ch_sel = gamma_ch_sel;
    beta_ch_sel = gamma_ch_sel;
else
    
    alpha_ch_sel = (abs(ch_pow_alpha) >= chan_crit*max(abs(ch_pow_alpha))) & ...
        (sign(ch_pow_alpha).*sign(ch_pow_alpha(abs(ch_pow_alpha) == max(abs(ch_pow_alpha))))==1);

    beta_ch_sel = (abs(ch_pow_beta) >= chan_crit*max(abs(ch_pow_beta))) & ...
        (sign(ch_pow_beta).*sign(ch_pow_beta(abs(ch_pow_beta) == max(abs(ch_pow_beta))))==1);
end

%% compute onsets, durations, parmod for alpha, beta, gamma and (non-artifact) task-regressors
L_alpha_pow=[];L_beta_pow=[];L_gamma_pow=[]; R_alpha_pow=[];R_beta_pow=[];R_gamma_pow=[];
L_pow_onsets=[]; R_pow_onsets=[];L_pow_bloks =[];R_pow_bloks =[];

mark_offset=0.140;
slicetime_offset=-0.5*0.3;

l_ind=1;
r_ind=1;
for i=1:length(TFData_all_low.trialinfo)
    strt=TFData_all_low.trialinfo(i,5)+mark_offset+slicetime_offset;
        
    if TFData_all_low.trialinfo(i,6).*TFData_all_low.trialinfo(i,7).*TFData_all_low.trialinfo(i,30)==1
        L_alpha_pow=[L_alpha_pow; squeeze(mean(mean(TFData_all_low.powspctrm(i,alpha_ch_sel,alpha_bins,tim_bins),3),2))];
        L_beta_pow=[L_beta_pow; squeeze(mean(mean(TFData_all_low.powspctrm(i,beta_ch_sel,beta_bins,tim_bins),3),2))];
        
        L_gamma_pow=[L_gamma_pow; squeeze(mean(mean(TFData_all_high.powspctrm(i,gamma_ch_sel,gamma_bins,tim_bins),3),2))];
        
        L_pow_onsets = [L_pow_onsets strt:0.1:strt+1.6];
        L_pow_bloks = [L_pow_bloks  TFData_all_low.trialinfo(i,2)*ones(1,17)];
        
        L_task_sel(l_ind,1:3) = [strt 1.6 1];
        
        L_task_blok(l_ind)=TFData_all_low.trialinfo(i,2);
        
        L_task_trl(l_ind)=TFData_all_low.trialinfo(i,1);
        
        l_ind=l_ind+1;
        
    elseif TFData_all_low.trialinfo(i,6).*TFData_all_low.trialinfo(i,7).*TFData_all_low.trialinfo(i,30)==2
        R_alpha_pow=[R_alpha_pow; squeeze(mean(mean(TFData_all_low.powspctrm(i,alpha_ch_sel,alpha_bins,tim_bins),3),2))];
        R_beta_pow=[R_beta_pow; squeeze(mean(mean(TFData_all_low.powspctrm(i,beta_ch_sel,beta_bins,tim_bins),3),2))];
        
        R_gamma_pow=[R_gamma_pow; squeeze(mean(mean(TFData_all_high.powspctrm(i,gamma_ch_sel,gamma_bins,tim_bins),3),2))];
        R_pow_bloks = [R_pow_bloks  TFData_all_low.trialinfo(i,2)*ones(1,17)];
        
        R_pow_onsets = [R_pow_onsets strt:0.1:strt+1.6];
        
        
        R_task_sel(r_ind,1:3) = [strt 1.6 1];
        
        R_task_blok(r_ind)=TFData_all_low.trialinfo(i,2);
        
        R_task_trl(r_ind)=TFData_all_low.trialinfo(i,1);
        
        r_ind=r_ind+1;
    end
end
%% make reg matrices
reg_alpha_L(:,1)=L_pow_onsets'; reg_alpha_L(:,3)=L_alpha_pow; reg_alpha_L(:,4)=L_pow_bloks'; 
reg_beta_L(:,1)=L_pow_onsets'; reg_beta_L(:,3)=L_beta_pow; reg_beta_L(:,4)=L_pow_bloks';
reg_gamma_L(:,1)=L_pow_onsets'; reg_gamma_L(:,3)=L_gamma_pow; reg_gamma_L(:,4)=L_pow_bloks';

reg_alpha_R(:,1)=R_pow_onsets'; reg_alpha_R(:,3)=R_alpha_pow; reg_alpha_R(:,4)=R_pow_bloks'; 
reg_beta_R(:,1)=R_pow_onsets'; reg_beta_R(:,3)=R_beta_pow; reg_beta_R(:,4)=R_pow_bloks';
reg_gamma_R(:,1)=R_pow_onsets'; reg_gamma_R(:,3)=R_gamma_pow; reg_gamma_R(:,4)=R_pow_bloks';

reg_task_L=[L_task_sel L_task_blok'];
reg_task_R=[R_task_sel R_task_blok'];

%% nuisance_regs
nuisance_ind=1;

%specify nuisance vars here:

%fixation dim
nuis_regs{nuisance_ind}(:,1) = [TFData_all_low.trialinfo(:,5)+mark_offset+slicetime_offset] - 1.2;
nuis_regs{nuisance_ind}(:,2) = 1.2;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(:,2);

nuis_names{nuisance_ind} = 'fix_dim';

nuisance_ind=nuisance_ind+1;

%correct oddball left 
trls=(TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)>10) &...
(TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)<15);% &...
%logical(TFData_all_low.trialinfo(:,7));

if sum(trls)>0
nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
nuis_regs{nuisance_ind}(:,2) = 1.6;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) =  TFData_all_low.trialinfo(trls,2);

nuis_names{nuisance_ind} = 'correct_target_L';

nuisance_ind=nuisance_ind+1;
end


%correct oddball right
trls=(TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)>20); %&...
%logical(TFData_all_low.trialinfo(:,7));
if sum(trls)>0
nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
nuis_regs{nuisance_ind}(:,2) = 1.6;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) =  TFData_all_low.trialinfo(trls,2);

nuis_names{nuisance_ind} = 'correct_target_R';

nuisance_ind=nuisance_ind+1;
end

%incorrect standard left
%trls=logical(TFData_all_low.trialinfo(:,11));
trls=(~TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6))==1;
if sum(trls)>0
nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
nuis_regs{nuisance_ind}(:,2) = 1.6;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) =  TFData_all_low.trialinfo(trls,2);

nuis_names{nuisance_ind} = 'incorrect_standard_L';

nuisance_ind=nuisance_ind+1;
end

%incorrect standard right 
trls=(~TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6))==2;
if sum(trls)>0
nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
nuis_regs{nuisance_ind}(:,2) = 1.6;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) =  TFData_all_low.trialinfo(trls,2);

nuis_names{nuisance_ind} = 'incorrect_standard_R';

nuisance_ind=nuisance_ind+1;
end

%incorrect oddball left
trls=(~TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)>10) &...
(~TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)<15);
if sum(trls)>0
nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
nuis_regs{nuisance_ind}(:,2) = 1.6;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) =  TFData_all_low.trialinfo(trls,2);

nuis_names{nuisance_ind} = 'incorrect_target_L';

nuisance_ind=nuisance_ind+1;
end


%incorrect oddball right
trls=(~TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)>20);
if sum(trls)>0
nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
nuis_regs{nuisance_ind}(:,2) = 1.6;
nuis_regs{nuisance_ind}(:,3) = 1;
nuis_regs{nuisance_ind}(:,4) =  TFData_all_low.trialinfo(trls,2);

nuis_names{nuisance_ind} = 'incorrect_target_R';

nuisance_ind=nuisance_ind+1;
end

% artifactual trial, standard left
if sum(TFData_all_low.trialinfo(:,10).*~TFData_all_low.trialinfo(:,30))>0
    trls=logical(TFData_all_low.trialinfo(:,10).*~TFData_all_low.trialinfo(:,30));
    nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
    nuis_regs{nuisance_ind}(:,2) = 1.6;
    nuis_regs{nuisance_ind}(:,3) = 1;
    nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
    
    nuis_names{nuisance_ind} = 'correct_target_art_L';
    
    nuisance_ind=nuisance_ind+1;
end

% artifactual trial, standard right
if sum(TFData_all_low.trialinfo(:,12).*~TFData_all_low.trialinfo(:,30))>0
    trls=logical(TFData_all_low.trialinfo(:,12).*~TFData_all_low.trialinfo(:,30));
    nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
    nuis_regs{nuisance_ind}(:,2) = 1.6;
    nuis_regs{nuisance_ind}(:,3) = 1;
    nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
    
    nuis_names{nuisance_ind} = 'correct_target_art_R';    
    
    nuisance_ind=nuisance_ind+1;
end

%
rt_regs_ind=1;

%Button_presses
trls = TFData_all_low.trialinfo(:,8)>0;
rt_regs{rt_regs_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset+TFData_all_low.trialinfo(trls,8);
rt_regs{rt_regs_ind}(:,2) = 0;
rt_regs{rt_regs_ind}(:,3) = 1;
rt_regs{rt_regs_ind}(:,4) = TFData_all_low.trialinfo(trls,2);

rt_names{rt_regs_ind} = 'button_press';

rt_regs_ind=rt_regs_ind+1;

% left correct RT par mod
trls=(TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)>10) &...
(TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)<15);

mean_rt=mean(TFData_all_low.trialinfo(trls,8));

if sum(trls)>0
    rt_regs{rt_regs_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
rt_regs{rt_regs_ind}(:,2) = mean_rt;
rt_regs{rt_regs_ind}(:,3) = TFData_all_low.trialinfo(trls,8);
rt_regs{rt_regs_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
end

rt_names{rt_regs_ind} = 'rt_pmod_L';

rt_regs_ind=rt_regs_ind+1;

% right correct RT par mod
trls=(TFData_all_low.trialinfo(:,7).*TFData_all_low.trialinfo(:,6)>20);

mean_rt=mean(TFData_all_low.trialinfo(trls,8));

if sum(trls)>0
    rt_regs{rt_regs_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
rt_regs{rt_regs_ind}(:,2) = mean_rt;
rt_regs{rt_regs_ind}(:,3) = TFData_all_low.trialinfo(trls,8);
rt_regs{rt_regs_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
end

rt_names{rt_regs_ind} = 'rt_pmod_R';

rt_regs_ind=rt_regs_ind+1;

%%
trialinfo=TFData_all_low.trialinfo;
if exist([savedir_stem sj])==0
    mkdir([savedir_stem sj])
end
save([savedir_stem sj '/reg_onsets_pow_task.mat'], 'reg*', 'nuis_regs', 'nuis_names', 'rt_regs', 'rt_names', 'trialinfo');
