

% mainpath=['P:' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];
cd([mainpath '/../4_retinotopy'])

disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
disp('done.')

disp('loading stimuli...')
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'images.mat']);
disp('done.')

% select non-empty screens and binarize stimuli
stims=images(:,:,squeeze(sum(sum(images==128)))~=(numel(images)./(size(images,3))))~=128;

% remove equal frames
% tmp=stims(:,:,1);
% for n=2:size(stims,3)
%     if ~isequal(tmp(:,:,end),stims(:,:,n))     
%         tmp=cat(3,tmp,stims(:,:,n));
%     end
% end
% 
% stims=tmp;
% 
% %   in here I "extrapolate" the number of different stimuli (64)
% %   to fit the retinotopy volumes per Block (128), hence for all different
% %   binarized stimulus two volumes were collected for each Block. This was
% %   done in order to replace the interpolation of the volume time series.
% tmp=zeros(size(stims,1),size(stims,2),size(stims,3).*2);
% tmp(:,:,1:2:end)=stims;
% tmp(:,:,2:2:end)=stims;
% 
% stims=tmp;

disp('loading gray matter mask...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
mask = load_untouch_nii(filetouse);
disp('done.')

ind=mask.img>mask_threshold;

disp('loading functionals...')
datatmp=cell(numblocks,1);
stimsin=cell(numblocks,1);
for n=[1:numblocks]-1
    
    filetouse=[mainpath filesep '..' filesep '3_distcorrection' filesep 'corrected_test_ret_mcf' num2str(n) '.nii'];
    if exist(filetouse,'file')==0
        unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
    end
    data = load_untouch_nii(filetouse);
        
    data_use=reshape(data.img,[],size(data.img,4));
    data_use=data_use(ind,:);
    
    downsamplingfactor=floor(size(stims,1)/size_stims_new);
    num_input_volumes_per_block=size(data.img,4);
    num_stims_per_block=size(stims,3);
    mult=floor(num_stims_per_block/num_input_volumes_per_block);
    stim_range=num_input_volumes_per_block*mult;
    
    stimsin{n+1}=double(stims(1:downsamplingfactor:end,1:downsamplingfactor:end,1:stim_range));
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
data_int = tseriesinterp(data_use,TR,TR/mult,2);
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
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat'],'ind','mult','mask_threshold','-v7.3')
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'images_downsampled.mat'],'images','-v7.3')
disp('done.')
%%
exit
