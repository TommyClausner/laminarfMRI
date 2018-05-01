mainpath= '/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P31/B_scripts';


% mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P31/B_scripts';
cd([mainpath '/../4_retinotopy'])

disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
disp('done.')

disp('loading stimuli...')
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'images.mat']);
disp('done.')

disp('loading gray matter mask...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
mask = niiload(filetouse,[],[],0);
disp('done.')

TR=2.7;
numblocks=3;
size_stims_new=40;
mask_threshold=0.9;
mask=mask>mask_threshold;

disp('loading functionals...')
datatmp=cell(numblocks,1);
stimsin=cell(numblocks,1);
for n=[1:numblocks]-1
    
    filetouse=[mainpath filesep '..' filesep '1_realignment' filesep 'ret_mcf' num2str(n) '.nii'];
    if exist(filetouse,'file')==0
        unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
    end
    data = niiload(filetouse,[],[],0);
    
    downsamplingfactor=floor(size(images,1)/size_stims_new);
    num_input_volumes_per_block=size(data,2);
    num_stims_per_block=size(images,3);
    mult=floor(num_stims_per_block/num_input_volumes_per_block);
    stim_range=num_input_volumes_per_block*mult;
    
    stimsin{n+1}=single(images(1:downsamplingfactor:end,1:downsamplingfactor:end,1:stim_range));
    datatmp{n+1}=single(data(mask,:));
end
disp('done.')

images=stimsin;
stimsin=[]; % to efficiently free system memory
clear stimsin
data=datatmp;
datatmp=[]; % to efficiently free system memory
clear datatmp
%
disp('resampling functionals...')
if matlabpool('size')<1
    matlabpool open;
end

data = tseriesinterp(data,TR,TR/mult,numel(size(data)));

ind=find(mask);
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'interpolatedTseries.mat'],'data','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'mask.mat'],'mask','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat'],'ind','mult','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'images_downsampled.mat'],'images','-v7.3')
disp('done.')
exit
