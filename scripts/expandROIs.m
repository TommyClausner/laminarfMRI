% mainpath=[filesep 'project' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];
disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
addpath(genpath(mainpath))
disp('done.')
cd([mainpath filesep '..' filesep '4_retinotopy'])

disp('loading stimuli...')
load([mainpath filesep '..' filesep 'A_helperfiles' filesep 'images.mat']);
disp('done.')

disp('loading gray matter mask...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
mask = load_untouch_nii(filetouse);
disp('done.')

areas={'lhV1mask',...
    'lhV2mask',...
    'lhV3mask',...
    'rhV1mask',...
    'rhV2mask',...
    'rhV3mask'};

disp('loading area masks...')
ROIvolumes={};
for area=areas
    filetouse=[mainpath filesep '..' filesep '4_retinotopy' filesep area{1} '.nii'];
    if exist(filetouse,'file')==0
        unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
    end
    
    tmp=load_untouch_nii(filetouse);
    tmp.img(tc_expandVoxelSelection(size(tmp.img),find(tmp.img>maskthreshold),ExpansionFactor))=1;
    tmp.img=single(tmp.img).*single(mask.img>maskthreshold);
    ROIvolumes = cat(1,ROIvolumes,{tmp});
end
disp('done.')

disp('saving expanded area masks...')
for n=1:numel(ROIvolumes)
    save_untouch_nii(ROIvolumes{n},[mainpath filesep '..' filesep '4_retinotopy' filesep areas{n} '_expanded.nii']);
end
disp('done.')

%%
exit
