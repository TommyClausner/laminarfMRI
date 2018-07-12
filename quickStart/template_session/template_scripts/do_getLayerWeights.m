%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'OpenFmriAnalysis'])
tvm_installOpenFmriAnalysisToolbox

%%
cd([mainpath filesep '..' filesep '5_laminar'])

disp('loading layers file...')
filetouse=[mainpath filesep '..' filesep '5_laminar' filesep 'brain.layers.nii'];
LayerVolume = load_untouch_nii(filetouse);
Layers=double(LayerVolume.img(:,:,:,2:4));
CSFwhite = double(LayerVolume.img(:,:,:,[1,5]));
disp('done.')

areas={'lhV1mask',...
    'lhV2mask',...
    'lhV3mask',...
    'rhV1mask',...
    'rhV2mask',...
    'rhV3mask'};

disp('loading area masks...')
ROIvolumes={};

allLaminarROIs=LayerVolume;
size_=size(allLaminarROIs.img);
size_=size_(1:3);
allLaminarROIs.img=zeros(size_);
allLaminarROIs.hdr.dime.dim([1,5])=[3,1];

CSFwhiteVol=LayerVolume;
CSFwhiteVol.hdr.dime.dim([1,5])=[3,1];
CSFwhiteVol.img=CSFwhite;

indexValuesAreas = 0:4:20;

multiplier = [indexValuesAreas;indexValuesAreas+1;indexValuesAreas+2];
counter=0;
for area=areas
    counter=counter+1;
    filetouse=[mainpath filesep '..' filesep '4_retinotopy' filesep area{1} '_expanded.nii'];
    tmp=load_untouch_nii(filetouse);
    tmp2=LayerVolume;
    tmp2.img=tmp.img;
    tmp2.img=double(repmat(tmp2.img,[1,1,1,3])).*Layers;
    tmp2.hdr.dime.dim(5)=size(Layers,4);
    ROIvolumes = cat(1,ROIvolumes,{tmp2});
    allLaminarROIs.img = allLaminarROIs.img + cat(4,...
        tmp2.img.*ones(size_).*multiplier(1,counter),...
        tmp2.img.*ones(size_).*multiplier(2,counter),...
        tmp2.img.*ones(size_).*multiplier(3,counter));
end

disp('saving expanded area masks...')
for n=1:numel(ROIvolumes)
    save_untouch_nii(ROIvolumes{n},[mainpath filesep '..' filesep '5_laminar' filesep areas{n} '_layers.nii']);
end
save_untouch_nii(allLaminarROIs,[mainpath filesep '..' filesep '5_laminar' filesep 'allLaminarROIs.nii']);
disp('done.')

disp('saving CSFwhiteVol...')
save_untouch_nii(CSFwhiteVol,[mainpath filesep '..' filesep '5_laminar' filesep 'CSFwhiteVol_lay.nii']);
disp('done.')

%%
exit