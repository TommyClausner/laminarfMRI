
% mainpath=['P:' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];

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
new_inds=floor(size(ind,1)/parts);
new_inds=[0:new_inds:size(ind,1)];
new_inds(end)=size(ind,1);

ind_sel=new_inds(partnum)+1:new_inds(partnum+1);

for n=1:size(data,1)
    data{n}=data{n}(ind_sel,:);
end

seedmode=struct('seedmode',ones(size(data))'.*2);

if exist('avgdata','var')>0
    if avgdata
        data=mean(cat(numel(size(data{1}))+1,data{:}),numel(size(data{1}))+1);
        
        imagesizes=cellfun(@(x) size(x,3),images);
        
        if all(imagesizes==imagesizes(1))
            images=mean(cat(numel(size(images{1}))+1,images{:}),numel(size(images{1}))+1);
        else
            [~,I]=max(imagesizes);
            images=images{I}(:,:,1:size(data,2));
        end
        ana_add_string=[ana_add_string 'avg'];
        seedmode=struct('seedmode',[2]);
    end
end

results = analyzePRF(images,data,TR/mult,seedmode);
save([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_part_' num2str(partnum)  '_of_' num2str(parts) '_' ana_add_string '.mat'],'results','-v7.3')
disp('done.')
%%
exit
