%mainpath=[filesep 'project' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];
%cd([mainpath filesep '..' filesep '4_retinotopy'])
disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
disp('done.')
data=struct('data',[],'maskgray',[],'maskwhite',[],'transmats',[],'transvecs',[]);

disp('loading gray matter mask...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
data.maskgray = niiload(filetouse,[],[],0);
disp('done.')

disp('loading white matter mask...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctwhitemattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
data.maskwhite = niiload(filetouse,[],[],0);
disp('done.')

disp('loading functional data...')
for n=[0,1,2,3]
    
    filetouse=[mainpath filesep '..' filesep '3_distcorrection' filesep '*corrected*test_task*' num2str(n) '.nii'];
    if exist(filetouse,'file')==0
        unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
    end
    data.data = cat(3,data.data,niiload(filetouse,[],[],0));
    
end
disp('done.')

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
data.transmats=transmats; % size(data.transmats); 4 x 4 x 240 x 4
data.transvecs=transvecs; % size(data.transmats); 1 x 6 x 240 x 4
disp('done.')

disp('saving data...')
save([filesep 'project' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'transfer_to_Rene' filesep 'all_task_blocks_P31.mat'],'data','-v7.3')
disp('done.')
%%
exit