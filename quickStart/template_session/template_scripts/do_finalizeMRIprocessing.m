%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'analyzePRF']))
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'knkutils'])
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'vistasoft-master']))
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions'])

disp('done.')
data=struct('data',[],'maskgray',[],'maskwhite',[],'maskecc',[],'transmats',[],'transvecs',[],...
    'layerROIs',struct('lh',struct('V1',[],'V2',[],'V3',[]),'rh',struct('V1',[],'V2',[],'V3',[])),'CSFwhite',[]);

disp('loading gray matter mask...')
filetouse=[mainpath filesep '..' filesep '3_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
data.maskgray = load_untouch_nii(filetouse);
data.maskgray = data.maskgray.img(:);
disp('done.')

disp('loading white matter mask...')
filetouse=[mainpath filesep '..' filesep '3_coregistration' filesep 'fctwhitemattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
data.maskwhite = load_untouch_nii(filetouse);
data.maskwhite = data.maskwhite.img(:);
disp('done.')

disp('loading functional data...')
for n=[0,1,2,3]
    
    filetouse=[mainpath filesep '..' filesep '2_distcorrection' filesep '*corrected_test_task_mcf' num2str(n) '.nii'];
    if exist(filetouse,'file')==0
        unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
    end
    tmp = load_untouch_nii(filetouse);
    tmp = reshape(tmp.img(:),[],size(tmp.img,4));
    data.data = cat(3,data.data,single(tmp));
end
%
disp('done.')
%
disp('loading motion parameters...')
motionparameters=dir([mainpath filesep '..' filesep '1_realignment' filesep 'task_mcf*.mat']);

motionparameterspaths=[motionparameters(1).folder filesep];
motionparametersfolders={motionparameters(:).name};

transmats=[];
transvecs=[];

for currentfolder=cellfun(@(x) [motionparameterspaths x filesep],motionparametersfolders,'unif',0)
    currentfiles=dir([currentfolder{1} '*MAT*']);
    
    transmatsinfolder=[];
    transvecsinfolder=[];
    for currentfile={currentfiles(:).name}
        currentmatrix=dlmread([currentfolder{1} currentfile{1}]);
        transmatsinfolder=cat(3,transmatsinfolder,currentmatrix);
        transvecsinfolder=cat(3,transvecsinfolder,tc_transmat2vec(currentmatrix));
    end
    transmats=cat(4, transmats,transmatsinfolder);
    transvecs=cat(4, transvecs,transvecsinfolder);
end
data.transmats=transmats; % size(data.transmats); 4 x 4 x 180 x 4
data.transvecs=transvecs; % size(data.transmats); 1 x 6 x 180 x 4
disp('done.')

disp('loading and prepare eccentricity map...')

ecc_sel=[0.6 3.4];

filetouse=[mainpath filesep '..' filesep '4_retinotopy' filesep 'ecc_map.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end

ecc_=load_untouch_nii(filetouse);
ecc_=flatten(ecc_.img)./2;
ecc_=ecc_>=ecc_sel(1) & ecc_<=ecc_sel(2);
data.maskecc=ecc_';
disp('done.')

disp('loading layer ROIs data...')
for n=[1,2,3]
    for hem ={'lh','rh'}
        
        filetouse=[mainpath filesep '..' filesep '5_laminar' filesep [hem{1} 'V' num2str(n) 'mask_layers.nii']];
        if exist(filetouse,'file')==0
            unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
        end
        % each ROI is of shape N_voxel x N_layer
        tmp = load_untouch_nii(filetouse);
        tmp = reshape(tmp.img(:),[],3);
        eval(['data.layerROIs.' hem{1} '.V' num2str(n) '= tmp;']);
    end
end
disp('done.')

disp('loading CSFwhiteVol data...')
filetouse=[mainpath filesep '..' filesep '5_laminar' filesep 'CSFwhiteVol_lay.nii'];
tmp = load_untouch_nii(filetouse);
tmp = reshape(tmp.img(:),[],2);
data.CSFwhite=tmp;
disp('done.')

disp('saving data...')
save([mainpath filesep '..' filesep '7_results' filesep 'MRIprocessed.mat'],'data','-v7.3')
disp('done.')
%%
exit
