function filt = fun_make_filt_regs(filt_freq_req, n_trls, n_scans_per_trial, TR, Pause, chunksize)
%% adapted from Rene Scheeringa (2018, DCCN)
% number of filter rgs are rounded up, su ginving at least one fliter
% frequency

pseudo_vols_scan=TR/chunksize;
pseudo_vols_pause=Pause/chunksize;

nr_vols=n_trls*n_scans_per_trial*pseudo_vols_scan+pseudo_vols_pause*n_trls;%not including first 4 volmes that were skipped here

rmv=[];
for trial =1:n_trls
    rmv=cat(2,rmv, [1.5*pseudo_vols_pause:pseudo_vols_scan:1.5*pseudo_vols_pause+...
        (n_scans_per_trial-1)*pseudo_vols_scan]+(trial-1)*...
        (n_scans_per_trial*pseudo_vols_scan+pseudo_vols_pause));    
end

chunksize_ms=chunksize/1000;

time=linspace(0.3,chunksize_ms*nr_vols, nr_vols);
time_2pi=time(end)./(2*pi);

nr_regs=ceil(filt_freq_req/(1/time(end)));

c=zeros(nr_vols, nr_regs);
s=zeros(size(c));

for reg=1:nr_regs
    c(:,reg)=cos(reg*(time/time_2pi));
    s(:,reg)=sin(reg*(time/time_2pi));
end

filt.regs=[c(rmv,:) s(rmv,:)];
filt.requested_freq=filt_freq_req;
filt.real_freq=nr_regs/time(end);