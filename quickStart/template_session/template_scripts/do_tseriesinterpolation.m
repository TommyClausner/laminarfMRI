%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'analyzePRF']))
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'knkutils']))
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions']))
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'OpenFmriAnalysis'])
tvm_installOpenFmriAnalysisToolbox
%%
cd([mainpath '/../4_retinotopy'])

disp('loading stimuli...')
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'images.mat']);
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'params.mat']);
disp('done.')

disp('loading gray matter mask...')
filetouse=[mainpath filesep '..' filesep '3_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
mask = load_untouch_nii(filetouse);
disp('done.')

if ~exist('mask_threshold', 'var')
    mask_threshold=0;
end

if ~exist('numblocks', 'var')
    numblocks=3;
end

if ~exist('size_stims_new', 'var')
    size_stims_new=100;
end

ind=mask.img>mask_threshold;

stims=cell(numblocks,1);

disp('loading and preparing retinotopy results...')
fcont=dir([mainpath filesep '..' filesep 'rawData' filesep 'retinotopy' filesep '*.mat']);

for block=1:numblocks
    load([fcont(block).folder filesep fcont(block).name])
    % reslice stimuli
    stims{block}=tc_reslice_vistadisp_stimuli(images,params,stimulus.seq);
end
disp('done.')

disp('loading functionals...')
datatmp=cell(numblocks,1);
stimsin=cell(numblocks,1);
for n=[1:numblocks]-1
    
    filetouse=[mainpath filesep '..' filesep '2_distcorrection' filesep 'corrected_test_ret_mcf' num2str(n) '.nii'];
    if exist(filetouse,'file')==0
        unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
    end
    data = load_untouch_nii(filetouse);
        
    data_use=reshape(data.img,[],size(data.img,4));
    data_use=data_use(ind,:);
    
    downsamplingfactor=floor(size(stims{n+1},1)/size_stims_new);
    num_input_volumes_per_block=size(data.img,4);
    num_stims_per_block=size(stims{n+1},3);
    mult=floor(num_stims_per_block/num_input_volumes_per_block);
    stim_range=num_input_volumes_per_block*mult;
    
    stimsin{n+1}=double(stims{n+1}(1:downsamplingfactor:end,1:downsamplingfactor:end,1:stim_range));
    datatmp{n+1}=double(data_use);
end

disp('done.')

images=stimsin;
stimsin=[]; % to efficiently free system memory
clear stimsin
data_use=datatmp;
datatmp=[]; % to efficiently free system memory
clear datatmp
%%
tic
disp('resampling functionals...')
data_int=data_use;
TR=params.framePeriod;
if mult ~=1
data_int = tseriesinterp(data_int,TR,TR/mult,2);
end
disp(['done after ' num2str(round(toc)) ' seconds.']);
%% normalize data
disp('normalizing functionals...');
for n=1:size(data_int,1)
   data_int_corr{n}= (data_int{n}./(mean(data_int{n},2)*ones(1,size(data_int{n},2))))*100;
end
disp('done.');
%%
tIntData=data_int_corr';
ind=find(ind);

disp('saving data...');
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'interpolatedTseries.mat'],'tIntData','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'mask.mat'],'mask','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat'],'TR','ind','mult','mask_threshold','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'images_downsampled.mat'],'images','-v7.3')
disp('done.')
%%
exit
