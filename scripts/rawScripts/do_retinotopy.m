



disp('setting up environment...')
addpath(genpath(['mainpath filesep '..' filesep '..' filesep toolboxes']))
disp('done.')
TR=2.7;
numblocks=3;
downsamplingfactor=3;

disp('loading stimuli...')
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'RetStim.mat']);
disp('done.')

disp('loading functionals...')
data = niiload([mainpath filesep '..' filesep '4_retinotopy' filesep 'ret.nii'],[],[],0);
disp('done.')

num_input_volumes_per_block=size(data,2)/numblocks;

num_stims_per_block=size(new_stims,3);

mult=floor(num_stims_per_block/num_input_volumes_per_block);

stim_range=num_input_volumes_per_block*mult;


disp('preparing stimuli and data...')
stimsin=cell(numblocks,1);
datatmp=cell(numblocks,1);
for n=1:numblocks
    stimsin{n}=single(new_stims(1:downsamplingfactor:end,1:downsamplingfactor:end,1:stim_range));
    datatmp{n}=single(data(:,(n-1)*num_input_volumes_per_block+1:n*num_input_volumes_per_block));
end
new_stims=stimsin;
stimsin=[]; % to efficiently free system memory
clear stimsin
disp('done.')
data=datatmp;
datatmp=[]; % to efficiently free system memory
clear datatmp

disp('resampling functionals...')
poolobj = gcp('nocreate');
if isempty(poolobj)
parpool
end

data = tseriesinterp(data,TR,TR/mult,numel(size(data)));
disp('done.')

disp('doing pRF analysis...')
results = analyzePRF(new_stims,data,TR/mult,struct('seedmode',[0 1]));
disp('done.')

save([mainpath 'resultsPRF.mat'],'results','-v7.3')
exit
