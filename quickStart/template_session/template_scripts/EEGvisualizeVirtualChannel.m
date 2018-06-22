%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults


%%
headmodelType='FEM';
Selprefix = 'Beamf_';
load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' headmodelType '.mat']);

ROIDataFiles=dir([mainpath filesep '..' filesep '5_laminar' filesep '*_layers.nii']);
ROIfiles=cellfun(@(x) [ROIDataFiles(1).folder filesep x],{ROIDataFiles.name},'unif',0);

possibleFilters={'TCsel','BP40_80','BP8_32'};

ecc_sel=[0.6 3.4];

filetouse=[mainpath filesep '..' filesep '4_retinotopy' filesep 'ecc_map.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end

ecc_=ft_read_mri(filetouse);
ecc_=ecc_.anatomy./2;
ecc_=ecc_>=ecc_sel(1) & ecc_<=ecc_sel(2);

facepos=mean(cat(3,sourcemodel.pos(sourcemodel.tri(:,1),:),...
    sourcemodel.pos(sourcemodel.tri(:,2),:),...
    sourcemodel.pos(sourcemodel.tri(:,3),:)),3);
facecolor=0.8.*ones(size(sourcemodel.tri));
vertexcolor=0.5.*ones(size(sourcemodel.pos));

ROIcolors=[...
    hex2dec({'EE','22','0C'})';... % red
    hex2dec({'FF','93','00'})';... % orange
    hex2dec({'FA','E2','32'})';... % yellow
    hex2dec({'00','76','BA'})';... % deep blue
    hex2dec({'00','A2','FF'})';... % blue
    hex2dec({'16','E7','CF'})']./255; % cyan

Roicounter=0;

for ROIfile = ROIfiles
    Roicounter=Roicounter+1;
    ROI=ft_read_mri(ROIfile{1});
    
    nameROI=strsplit(ROIfile{1},'/');
    nameROI=strsplit(nameROI{end},'mask_');
    nameROI=nameROI{1};
    
    %EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix nameROI '*.mat']);
    %files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
    
    %load(files{1})
    
    %ROIvalues=dataSrc.avg.pow;
    
    trans=ROI.transform;
    ROI.anatomy=sum(ROI.anatomy,4);
    ROI=((ROI.anatomy>0).*ecc_);
    [x,y,z] = ind2sub(size(ROI),find(ROI));
    
    ROI = unique([x,y,z],'rows');
    
    ROIpos=ft_warp_apply(trans,ROI);
    
    
    [~,I]=min(pdist2(ROIpos,facepos),[],2);
    
    color=ROIcolors(Roicounter,:);
    
    facecolor(I,:)=color(ones(numel(I),1),:);
    
    [~,I]=min(pdist2(ROIpos, sourcemodel.pos),[],2);
    
    vertexcolor(I,:)=color(ones(numel(I),1),:);
end
ft_plot_mesh(sourcemodel,'facealpha',0.8,'vertexcolor',vertexcolor,'facecolor',facecolor);
camlight
%%
exit