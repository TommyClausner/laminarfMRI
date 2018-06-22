%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'analyzePRF']))
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'knkutils']))


%%
%parts=5;
%partnum=5;

disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat']);
disp('done.')

disp('loading stimuli...')
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'images_downsampled.mat']);
disp('done.')

disp('loading interpolated functionals...')
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'interpolatedTseries.mat']);
disp('done.')
%
disp('doing pRF analysis...')
TR=2.7;
ana_add_string='';

if partnum==parts
    ind_sel=(partnum-1)*floor(size(ind,1)/parts)+1:size(ind,1);
else
    ind_sel=linspace((partnum-1).*floor(size(ind,1)/parts)+1,...
    (partnum).*floor(size(ind,1)/parts),...
    floor(size(ind,1)/parts));   
end


%%
for n=1:size(tIntData,1)
    tIntData{n}=tIntData{n}(ind_sel,:);
end

seedmode=struct('seedmode',[0 1 2],'typicalgain',100);
if exist('avgdata','var')>0
    if avgdata
        tIntData={mean(cat(numel(size(tIntData{1}))+1,tIntData{:}),numel(size(tIntData{1}))+1)};
        images={mean(cat(numel(size(images{1}))+1,images{:}),numel(size(images{1}))+1)};
    end
end


%%
results = analyzePRF(images,tIntData,TR/mult,seedmode);
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_part_' num2str(partnum)  '_of_' num2str(parts) '_' ana_add_string '.mat'],'results','-v7.3')
disp('done.')
%%
exit
