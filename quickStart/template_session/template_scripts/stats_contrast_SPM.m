%% adapted from Rene Scheeringa (2018, DCCN)
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end

%% prepare design matrix
num_blocks = 4;
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'first_level_nosmth.mat'])
spm_jobman('run', matlabbatch)

fmri_spec = matlabbatch{1}.spm.stats.fmri_spec;

fmri_spec.dir = [mainpath filesep '..' filesep '7_results'];

session=[];

for n=1:num_blocks
    session = cat(1, session, struct(...% adjust scans
        'scans',{[mainpath filesep '..' filesep '2_distcorrection' filesep 'corrected_task_mcf' num2str(block) '.nii']},...
        'cont',struct ,...
        'multi', {''},...
        'regress',struct ,...
        'multi_reg',{[mainpath filesep '..' filesep '7_results' filesep 'DM_regs_B' num2str(block) '.mat']} ,...
        'hpf', Inf));
    
end


%% run model

load([mainpath filesep '..' filesep '7_results' filesep 'SPM.mat'])
spm_spm(SPM)


%% compute contrast

sj='P31';
load(['/project/3018037.01/Experiment3.2_ERC/tommys_folder/transfer_to_Rene/distCor_motCor_task/' sj '/regs/DM_B1.mat']);
SB1=size(R);

load(['/project/3018037.01/Experiment3.2_ERC/tommys_folder/transfer_to_Rene/distCor_motCor_task/' sj '/regs/DM_B2.mat']);
SB2=size(R);

load(['/project/3018037.01/Experiment3.2_ERC/tommys_folder/transfer_to_Rene/distCor_motCor_task/' sj '/regs/DM_B3.mat']);
SB3=size(R);

load(['/project/3018037.01/Experiment3.2_ERC/tommys_folder/transfer_to_Rene/distCor_motCor_task/' sj '/regs/DM_B4.mat']);
SB4=size(R);

act=[1 1 zeros(1, SB1(2)-2) 1 1 zeros(1, SB2(2)-2) 1 1 zeros(1, SB3(2)-2) 1 1 zeros(1, SB4(2)-2)];
deact=[-1 -1 zeros(1, SB1(2)-2) -1 -1 zeros(1, SB2(2)-2) -1 -1 zeros(1, SB3(2)-2) -1 -1 zeros(1, SB4(2)-2)];
LR=[1 -1 zeros(1, SB1(2)-2) 1 -1 zeros(1, SB2(2)-2) 1 -1 zeros(1, SB3(2)-2) 1 -1 zeros(1, SB4(2)-2)];
RL=[-1 1 zeros(1, SB1(2)-2) -1 1 zeros(1, SB2(2)-2) -1 1 zeros(1, SB3(2)-2) -1 1 zeros(1, SB4(2)-2)];

L=[1 0 zeros(1, SB1(2)-2) 1 0 zeros(1, SB2(2)-2) 1 0 zeros(1, SB3(2)-2) 1 0 zeros(1, SB4(2)-2)];
R=[0 1 zeros(1, SB1(2)-2) 0 1 zeros(1, SB2(2)-2) 0 1 zeros(1, SB3(2)-2) 0 1 zeros(1, SB4(2)-2)];

