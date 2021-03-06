%% adapted from Rene Scheeringa (2018, DCCN)
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults
%%
alpha_freqs = [8 12];
beta_freqs = [22.5 27.5];
gamma_freqs=[50 70];

timwin=[0 1.4];

low_bsln=[-0.3 -0.1];
high_bsln=[-0.3 -0.1];

EEGDataFiles=dir([mainpath filesep '..' filesep 'rawData' filesep 'eegfiles' filesep '*.eeg']);
files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
TrialPreStim=0.5;
TrialPostStim=1.6;


exclude_stims=[99, 101, 33, 51, 54];

for file_ = files
events = ft_read_event(file_{1});
end

Stimuli = cellfun(@(x) strcmpi(x, 'Stimulus'), {events.type});
S101 = find(cellfun(@(x) strcmpi(x, 'S101'), {events.value}));
for n = S101
    events(n).value = 'S 101';
end
StimuliValues = [{'something'},cellfun(@(x) strsplit(x, 'S '), {events(2:end).value},'unif', 0)];

first_A1 = find(cellfun(@(x) strcmpi(x, 'A  1'), {events.value}));

first_A1 = events(first_A1(1)).sample;

Stimuli(S101) = 1;

StimuliValues = cellfun(@(x) str2double(x{2}), StimuliValues(Stimuli));

sampling_rate = 5000; % Hz
Samples_in_ms = [events(Stimuli).sample]'./sampling_rate*1000 - first_A1/sampling_rate*1000;

exclude = ismember(StimuliValues, exclude_stims);

Samples_in_ms(exclude)=[];
StimuliValues(exclude)=[];

%correct = 

len_ = size(Samples_in_ms,1);

C_1 = [1:len_]';
C_2 = block*ones(len_,1);
C_5 = Samples_in_ms*1000;
C_6 = StimuliValues';
%C_7 = 
%C_8 = 


%% determine time bins to slect for power regressors, and for baseline for low and high frequencies
clear
mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P32/B_scripts';
cd(mainpath)

sj='P32';
cond='';
stem='/project/3018037.01/Experiment3.2_ERC/Data/EEG/';
savedir_stem = '/project/3018037.01/Experiment3.2_ERC/Data/regressors/';

load([stem sj '/' sj cond '_backprojected_TFR.mat'], 'TFData*');
load([mainpath filesep '..' filesep '7_results' filesep 'EEGprocessed.mat'])

alpha_freqs = VirtChanData(3).freqROIfreq;
beta_freqs = VirtChanData(5).freqROIfreq;
gamma_freqs=VirtChanData(1).freqROIfreq;

timwin=VirtChanData(1).tROI;
low_bsln=VirtChanData(3).baselineWin;
high_bsln=VirtChanData(1).baselineWin;

numtrials_per_block=50;
sample_size=0.02;
num_blocks=4;

%% determine frequency bins to average over for alpha, beta, gamma
alpha_bins=VirtChanData(3).ft_freqanalysis.freq>=alpha_freqs(1) & VirtChanData(3).ft_freqanalysis.freq<=alpha_freqs(2);
beta_bins=VirtChanData(5).ft_freqanalysis.freq>=beta_freqs(1) & VirtChanData(5).ft_freqanalysis.freq<=beta_freqs(2);
gamma_bins=VirtChanData(1).ft_freqanalysis.freq>=gamma_freqs(1) & VirtChanData(1).ft_freqanalysis.freq<=gamma_freqs(2);

%% determine time bins to slect for power regressors, and for baseline for low and high frequencies
tim_bins = VirtChanData(1).ft_freqanalysis.time>=timwin(1) & VirtChanData(1).ft_freqanalysis.time<=timwin(2);
%% compute onsets, durations, parmod for alpha, beta, gamma and (non-artifact) task-regressors
L_alpha_pow=[];L_beta_pow=[];L_gamma_pow=[]; R_alpha_pow=[];R_beta_pow=[];R_gamma_pow=[];
L_pow_onsets=[]; R_pow_onsets=[];L_pow_bloks =[];R_pow_bloks =[];

LR_alpha_pow=[];LR_beta_pow=[];LR_gamma_pow=[]; RR_alpha_pow=[];RR_beta_pow=[];RR_gamma_pow=[];


mark_offset=0.140;
slicetime_offset=-0.5*0.3;

l_ind=1;
r_ind=1;
for block = 1:num_blocks
    trlcounter=1;
for trial=1:numtrials_per_block
    trial_info_index=trial+ numtrials_per_block*(block-1);
    strt=TFData_all_low.trialinfo(trial_info_index,5)+mark_offset+slicetime_offset;
    
    if TFData_all_low.trialinfo(trial_info_index,6).*TFData_all_low.trialinfo(trial_info_index,7).*TFData_all_low.trialinfo(trial_info_index,30).*TFData_all_low.trialinfo(trial_info_index,31)==1
        L_alpha_pow=[L_alpha_pow; ...
            squeeze(mean(VirtChanData(3).ft_freqanalysis.powspctrm(trlcounter,1,alpha_bins,tim_bins, block),3))];
        L_beta_pow=[L_beta_pow; squeeze(mean(VirtChanData(5).ft_freqanalysis.powspctrm(trlcounter,1,beta_bins,tim_bins, block),3))];
        
        L_gamma_pow=[L_gamma_pow; squeeze(mean(VirtChanData(1).ft_freqanalysis.powspctrm(trlcounter,1,gamma_bins,tim_bins, block),3))];
        
        LR_alpha_pow=[LR_alpha_pow; ...
            squeeze(mean(VirtChanData(4).ft_freqanalysis.powspctrm(trlcounter,1,alpha_bins,tim_bins, block),3))];
        LR_beta_pow=[LR_beta_pow; squeeze(mean(VirtChanData(6).ft_freqanalysis.powspctrm(trlcounter,1,beta_bins,tim_bins, block),3))];
        
        LR_gamma_pow=[LR_gamma_pow; squeeze(mean(VirtChanData(2).ft_freqanalysis.powspctrm(trlcounter,1,gamma_bins,tim_bins, block),3))];
        
        
        L_pow_onsets = [L_pow_onsets strt+VirtChanData(3).tROI(1)+0.025:sample_size:strt+VirtChanData(3).tROI(2)];
        L_pow_bloks = [L_pow_bloks  block*ones(1,sum(tim_bins))];
        
        L_task_sel(l_ind,1:3) = [strt+VirtChanData(1).tROI(1) timwin(2) 1];
        
        L_task_blok(l_ind)=TFData_all_low.trialinfo(trial_info_index,2);
        
        L_task_trl(l_ind)=TFData_all_low.trialinfo(trial_info_index,1);
        
        l_ind=l_ind+1;
        trlcounter=trlcounter+1;
    elseif TFData_all_low.trialinfo(trial_info_index,6).*TFData_all_low.trialinfo(trial_info_index,7).*TFData_all_low.trialinfo(trial_info_index,30).*TFData_all_low.trialinfo(trial_info_index,31)==2
        R_alpha_pow=[R_alpha_pow; squeeze(mean(VirtChanData(3).ft_freqanalysis.powspctrm(trlcounter,1,alpha_bins,tim_bins, block),3))];
        R_beta_pow=[R_beta_pow; squeeze(mean(VirtChanData(5).ft_freqanalysis.powspctrm(trlcounter,1,beta_bins,tim_bins, block),3))];
        
        R_gamma_pow=[R_gamma_pow; squeeze(mean(VirtChanData(1).ft_freqanalysis.powspctrm(trlcounter,1,gamma_bins,tim_bins, block),3))];
        
        RR_alpha_pow=[RR_alpha_pow; ...
            squeeze(mean(VirtChanData(4).ft_freqanalysis.powspctrm(trlcounter,1,alpha_bins,tim_bins, block),3))];
        RR_beta_pow=[RR_beta_pow; squeeze(mean(VirtChanData(6).ft_freqanalysis.powspctrm(trlcounter,1,beta_bins,tim_bins, block),3))];
        
        RR_gamma_pow=[RR_gamma_pow; squeeze(mean(VirtChanData(2).ft_freqanalysis.powspctrm(trlcounter,1,gamma_bins,tim_bins, block),3))];
        
        
        R_pow_bloks = [R_pow_bloks  block*ones(1,sum(tim_bins))];
        
        R_pow_onsets = [R_pow_onsets strt+VirtChanData(1).tROI(1)+0.025:sample_size:strt+VirtChanData(1).tROI(2)];
        
        
        R_task_sel(r_ind,1:3) = [strt+VirtChanData(1).tROI(1) VirtChanData(1).tROI(2) 1];
        
        R_task_blok(r_ind)=TFData_all_low.trialinfo(trial_info_index,2);
        
        R_task_trl(r_ind)=TFData_all_low.trialinfo(trial_info_index,1);
        
        r_ind=r_ind+1;
        trlcounter=trlcounter+1;
    end
end
end
%% make reg matrices
clear reg_*
reg_alpha_LL(:,1)=L_pow_onsets'; reg_alpha_LL(:,3)=L_alpha_pow; reg_alpha_LL(:,4)=L_pow_bloks';
reg_beta_LL(:,1)=L_pow_onsets'; reg_beta_LL(:,3)=L_beta_pow; reg_beta_LL(:,4)=L_pow_bloks';
reg_gamma_LL(:,1)=L_pow_onsets'; reg_gamma_LL(:,3)=L_gamma_pow; reg_gamma_LL(:,4)=L_pow_bloks';

reg_alpha_RL(:,1)=R_pow_onsets'; reg_alpha_RL(:,3)=R_alpha_pow; reg_alpha_RL(:,4)=R_pow_bloks';
reg_beta_RL(:,1)=R_pow_onsets'; reg_beta_RL(:,3)=R_beta_pow; reg_beta_RL(:,4)=R_pow_bloks';
reg_gamma_RL(:,1)=R_pow_onsets'; reg_gamma_RL(:,3)=R_gamma_pow; reg_gamma_RL(:,4)=R_pow_bloks';

reg_alpha_LR(:,1)=L_pow_onsets'; reg_alpha_LR(:,3)=LR_alpha_pow; reg_alpha_LR(:,4)=L_pow_bloks';
reg_beta_LR(:,1)=L_pow_onsets'; reg_beta_LR(:,3)=LR_beta_pow; reg_beta_LR(:,4)=L_pow_bloks';
reg_gamma_LR(:,1)=L_pow_onsets'; reg_gamma_LR(:,3)=LR_gamma_pow; reg_gamma_LR(:,4)=L_pow_bloks';

reg_alpha_RR(:,1)=R_pow_onsets'; reg_alpha_RR(:,3)=RR_alpha_pow; reg_alpha_RR(:,4)=R_pow_bloks';
reg_beta_RR(:,1)=R_pow_onsets'; reg_beta_RR(:,3)=RR_beta_pow; reg_beta_RR(:,4)=R_pow_bloks';
reg_gamma_RR(:,1)=R_pow_onsets'; reg_gamma_RR(:,3)=RR_gamma_pow; reg_gamma_RR(:,4)=R_pow_bloks';



reg_task_L=[L_task_sel L_task_blok'];
reg_task_R=[R_task_sel R_task_blok'];

%% nuisance_regs
clear nuis_regs
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

% blink, standard left
if sum(TFData_all_low.trialinfo(:,10).*~TFData_all_low.trialinfo(:,31))>0
    trls=logical(TFData_all_low.trialinfo(:,10).*~TFData_all_low.trialinfo(:,31));
    nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
    nuis_regs{nuisance_ind}(:,2) = 1.6;
    nuis_regs{nuisance_ind}(:,3) = 1;
    nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
    
    nuis_names{nuisance_ind} = 'correct_standard_blink_L';
    
    nuisance_ind=nuisance_ind+1;
end

% blink, standard right
if sum(TFData_all_low.trialinfo(:,12).*~TFData_all_low.trialinfo(:,31))>0
    trls=logical(TFData_all_low.trialinfo(:,12).*~TFData_all_low.trialinfo(:,31));
    nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
    nuis_regs{nuisance_ind}(:,2) = 1.6;
    nuis_regs{nuisance_ind}(:,3) = 1;
    nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
    
    nuis_names{nuisance_ind} = 'correct_standard_blink_R';
    
    nuisance_ind=nuisance_ind+1;
end

% compute artifact trials without blinks
art_nobl=(~TFData_all_low.trialinfo(:,30)-~TFData_all_low.trialinfo(:,31))>0;

% artifactual trial, standard left
if sum(TFData_all_low.trialinfo(:,10).*art_nobl)>0
    trls=logical(TFData_all_low.trialinfo(:,10).*art_nobl);
    nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
    nuis_regs{nuisance_ind}(:,2) = 1.6;
    nuis_regs{nuisance_ind}(:,3) = 1;
    nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
    
    nuis_names{nuisance_ind} = 'correct_standard_art_L';
    
    nuisance_ind=nuisance_ind+1;
end

% artifactual trial, standard right
if sum(TFData_all_low.trialinfo(:,12).*art_nobl)>0
    trls=logical(TFData_all_low.trialinfo(:,12).*art_nobl);
    nuis_regs{nuisance_ind}(:,1) = TFData_all_low.trialinfo(trls,5)+mark_offset+slicetime_offset;
    nuis_regs{nuisance_ind}(:,2) = 1.6;
    nuis_regs{nuisance_ind}(:,3) = 1;
    nuis_regs{nuisance_ind}(:,4) = TFData_all_low.trialinfo(trls,2);
    
    nuis_names{nuisance_ind} = 'correct_standard_art_R';    
    
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
save([mainpath filesep '..' filesep '6_EEG' filesep 'reg_onsets_pow_task.mat'], 'reg*', 'nuis_regs', 'nuis_names', 'rt_regs', 'rt_names', 'trialinfo');
