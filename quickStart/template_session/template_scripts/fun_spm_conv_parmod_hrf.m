function fun_spm_conv_parmod_hrf(regs,config, templatepath)
%% adapted from Rene Scheeringa (2018, DCCN)
%Yse as:    regs_conv=conv_parmod_hrf(regs,config);
%
%This function convolves a costum made parametric regressor with the
%canonical HRF in SPM8. It assumes that a modified function spm_fmri_spm_ui
%is above spm8 in the path, and the temp_batch.mat file containing a
%template spm batch. regs{1:n} is a cell aray with the length n equal to
%the number of regressors that need ot be formed. Each cell in regs
%contains a m by 3 matrix, where the first column indicates the onsets of
%each of the m events, the second column indicates the duration of each event, and
%the third column indicates the parametric modulation. The parametric
%regressors are not computed if the third column is a constant (e.g.
%var(regs{i}(:,3))=0). The third clumn is then ignored. Onsets and durations are asumed to be in seconds. The config
%structure contains the folowing fields that specify how the regressor
%should be constructed:
%
%config.nr_vols= ?; The length of the regressor in volumes
%config.TR= ?; repetition time (TR) in seconds
%config.micro_time_res=?; microtime resolution, default =16;
%config.micro_time_onset='?' or ?; indicates whether slice timing correction is
%                       assumed. 'middle' indicates indicates slice time orrection to the middle slice, an integer number 
%                       asumes correction to that time-bin and must
%                       therefore be lower than config.micro_time_res, wrong or no imputs result in that the default (=1) is asumed
%
%The functiontemporally saves a SPM.mat file in the working directory.
%If an SPM.mat file is already present in the working directory, the containing SPM
%structure is temporaily stored in SPM_orig, and at the end of the function
%saved again as SPM in SPM.mat. Also temporarily a file temp_pars.mat is
%saved. Any file with such a name in the present working directory will be
%deleted.

%default micro-time
default_time=1;
%check for precence of SPM.mat file in working directory
if exist('SPM.mat','file')==2
    load('SPM.mat');
    SPM_orig=SPM;
    delete SPM.mat
end

%%
delete temp_parms.mat

%make name, onsets, durations and pmod cell-arrays
dum_par=0;
dum_design_reg=1;

pmod=struct('name',{''},'param',{},'poly',{});
for i=1:length(regs)
    names{i}=['r' num2str(i)];
    onsets{i}=regs{i}(:,1)';
    durations{i}=regs{i}(:,2);
    if i==1
        task_regs=1;
    else
        task_regs=[task_regs dum_design_reg];
    end
    dum_design_reg=dum_design_reg+1;
    
    if var(regs{i}(:,3))>0
        pmod(i).name{1}=['r' num2str(i)];
        pmod(i).poly{1}=1;
        pmod(i).param{1}=regs{i}(:,3)';
        if dum_par==0
            par_regs=dum_design_reg;
        else
            par_regs=[par_regs dum_design_reg];
        end
        dum_par=1;
        dum_design_reg=dum_design_reg+1;
    end
    
end

%save names onsets durations pmod
if dum_par==1
    save temp_parms.mat names onsets durations pmod
else
    clear pmod
    save temp_parms.mat names onsets durations
end

%load ad adjust template batch
load(templatepath)

matlabbatch{1,1}.spm.stats.fmri_spec.dir{1,1}=pwd;
matlabbatch{1,1}.spm.stats.fmri_spec.timing.RT=config.TR;
if isfield(config,'micro_time_res')
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t=config.micro_time_res;
else
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t=16;
end

if isfield(config,'micro_time_res')
    if isnumeric(config.micro_time_onset)
        if round(config.micro_time_onset)>config.micro_time_res
            config.micro_time_onset=default_time;
            warning(['config.micro_time_onset>config.micro_time_res, slice-time correction to micro time ' num2str(default_time) 'is asumed']);
        end
        disp(['Asuming slice-time correction to micro time onset' num2str(round(config.micro_time_onset)) ', onsets are asumed relative to start of first volume']);
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0=round(config.micro_time_res);
    elseif strcmp(config.micro_time_onset,'middle');
        disp(['Asuming slice-time correction to micro time onset equal to the middle slice, onsets are asumed relative to start of first volume']);
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0=round(config.micro_time_res/2);
    else
        disp(['Asuming slice-time correction to micro time onset' num2str(round(config.micro_time_onset)) ', onsets are asumed relative to start of first volume']);
        matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0=default_time;
    end
else
    disp(['Asuming slice-time correction to micro time onset' num2str(round(config.micro_time_onset)) ', onsets are asumed relative to start of first volume']);
    matlabbatch{1,1}.spm.stats.fmri_spec.timing.fmri_t0=default_time;
end

for i=1:config.nr_vols
    matlabbatch{1,1}.spm.stats.fmri_spec.sess.scans{i,1}=[pwd '/dummy' num2str(i) '.img'];
end

matlabbatch{1,1}.spm.stats.fmri_spec.sess.multi{1,1}=[pwd filesep 'temp_parms.mat'];

spm_jobman('run',matlabbatch);close;

load SPM.mat

%regs_conv.task=SPM.xX.X(:,1:2:2*length(regs));
%regs_conv.par=SPM.xX.X(:,2:2:2*length(regs));

if dum_par==1
    regs_conv.task=SPM.xX.X(:,task_regs);
    regs_conv.par=SPM.xX.X(:,par_regs);
else
    regs_conv.task=SPM.xX.X(:,task_regs);
end

delete SPM.mat temp_parms.mat

if exist('SPM_orig','var')==1
    SPM=SPM_orig;
    save SPM.mat SPM
end
