%% adapted from Rene Scheeringa (2018, DCCN)
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end

%%

load([mainpath filesep '..' '6_EEG' filesep 'reg_onsets_pow_task.mat']);

spmpath=[mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'spm12'];
templatepath=[mainpath filesep '..' filesep 'A_helperfiles' filesep 'template_batch.mat'];


n_trls=60;
n_scans_per_trial = 3;
TR=3300;
Pause=3000;
chunksize=300;

alpha_conv.L=fun_conv_power_reg(reg_alpha_L,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
alpha_conv.R=fun_conv_power_reg(reg_alpha_R,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);

beta_conv.L=fun_conv_power_reg(reg_beta_L,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
beta_conv.R=fun_conv_power_reg(reg_beta_R,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);

gamma_conv.L=fun_conv_power_reg(reg_gamma_L,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
gamma_conv.R=fun_conv_power_reg(reg_gamma_R,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);

%%

task_conv.L=fun_conv_task_reg(reg_task_L,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
task_conv.R=fun_conv_task_reg(reg_task_R,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);

%%
nuisreg_conv=fun_conv_nuis_reg(nuis_regs, nuis_names);

%%
rtreg_conv=fun_conv_nuis_reg(rt_regs, rt_names);

save([mainpath filesep '..' '6_EEG' filesep 'convolved_eeg_task_regressors.mat'], 'alpha_conv','beta_conv','gamma_conv','task_conv','nuisreg_conv','rtreg_conv');
%%
exit
