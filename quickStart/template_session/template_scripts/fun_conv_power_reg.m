function task_reg=fun_conv_power_reg(reg,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize)
%% Adapted from Rene Scheeringa (2018, DCCN)

reg(:,3)=zscore(reg(:,3));

if sum(reg(:,4)==1)>0
    temp{1}=reg(reg(:,4)==1,1:3);
    task_reg.b1=make_reg(tempspmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
end

if sum(reg(:,4)==2)>0
    temp{1}=reg(reg(:,4)==2,1:3);
    task_reg.b2=make_reg(temp,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
end

if sum(reg(:,4)==3)>0
    temp{1}=reg(reg(:,4)==3,1:3);
    task_reg.b3=make_reg(temp,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
end

if sum(reg(:,4)==4)>0
    temp{1}=reg(reg(:,4)==4,1:3);
    task_reg.b4=make_reg(temp,spmpath, templatepath,n_trls, n_scans_per_trial, TR, Pause, chunksize);
end