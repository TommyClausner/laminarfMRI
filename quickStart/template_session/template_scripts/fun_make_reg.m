function regs_sel=fun_make_reg(regs, spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize)
%% adapted from Rene Scheeringa (2018, DCCN)
addpath(spmpath)
%%
%clear
config.TR=chunksize/1000;
config.nr_vols=(n_trls*n_scans_per_trial+n_scans_per_trial)*(TR/chunksize)+(Pause/chunksize)*n_trls;
config.micro_time_res=15;
config.micro_time_onset='middle';

regs_conv=fun_spm_conv_parmod_hrf(regs,config, templatepath);


rmv=[];
for i =1:n_trls 
    rmv=cat(2,rmv, [1.5*pseudo_vols_pause:pseudo_vols_scan:1.5*pseudo_vols_pause+...
        (n_scans_per_trial-1)*pseudo_vols_scan]+(trial-1)*...
        (n_scans_per_trial*pseudo_vols_scan+pseudo_vols_pause));
end

regs_sel.task = detrend(regs_conv.task(rmv,:),'constant');
if isfield(regs_conv,'par')
regs_sel.par = detrend(regs_conv.par(rmv,:),'constant');
end
