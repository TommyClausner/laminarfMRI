%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults

%% Beamformer


headmodelType = 'FEM';
load([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' headmodelType '.mat']);
plotSource=0;

Selprefix='TL';

Addprefix='Beamf_centV1_';
if strcmp(headmodelType,'BEM')
    setenv('PATH', [filesep 'opt' filesep 'openmeeg' filesep '2.2.0' filesep 'bin:' getenv('PATH')]);
    setenv('LD_LIBRARY_PATH', [filesep 'opt' filesep 'openmeeg' filesep '2.2.0' filesep 'lib:' getenv('LD_LIBRARY_PATH')]);
end

% center of hexagons
ref_brain_headmodel=squeeze(mean(reshape(headmodel.pos(headmodel.hex(headmodel.tissue==1,:),:),[],8,3),2));

%% use ROI mask
ROIDataFiles=dir([mainpath filesep '..' filesep '5_laminar' filesep '*V1*_layers.nii']);
ROIfiles=cellfun(@(x) [ROIDataFiles(1).folder filesep x],{ROIDataFiles.name},'unif',0);

if ~exist('BlockSel','var')
    BlockSel=[1,2,3,4];
end

if ~exist('FiltSel','var')
    FiltSel=[1,2];
end

possibleFilters={'BP30_100','BP2_32'};
for block=BlockSel
    for SelFilter=FiltSel
        Filter=possibleFilters{SelFilter};
        
        for ROIfile = ROIfiles
            ROI=ft_read_mri(ROIfile{1});
            
            nameROI=strsplit(ROIfile{1},'/');
            nameROI=strsplit(nameROI{end},'mask_');
            nameROI=nameROI{1};
            
            trans=ROI.transform;
            
            ROI=sum(ROI.anatomy,4);
            
            [x,y,z] = ind2sub(size(ROI),find(ROI>0));
            
            ROI = unique([x, y, z],'rows');
            ROIpos=ft_warp_apply(trans,ROI);
            
            I = unique(dsearchn(ref_brain_headmodel,ROIpos));
            
            ROIpos=ref_brain_headmodel(I,:);
            
            EEGDataFiles=dir([mainpath filesep '..' filesep '6_EEG' filesep Selprefix '_' Filter '*B' num2str(block) '.mat']);
            files=cellfun(@(x) [EEGDataFiles(1).folder filesep x],{EEGDataFiles.name},'unif',0);
            
            for file_ = files
                load(file_{1})
                sens.label(1:numel(dataTL.label))=dataTL.label;
                cfg              = [];
                cfg.method       = 'lcmv';
                cfg.grid         = sourcemodel;
                
                % 3D-"plus" around the max T from task
                cfg.grid.pos     = ROIpos;%[7 -65 -15;6 -65 -15;8 -65 -15;7 -64 -15;7 -66 -15;7 -65 -16;7 -65 -14];
                cfg.grid.inside = true(size(ROIpos(:,1)));
                cfg.grid.unit    = headmodel.unit;
                cfg.headmodel    = headmodel;
                cfg.elec         = sens;
                cfg.lcmv.normalize   = 'yes';
                cfg.lcmv.projectnoise = 'yes';
                cfg.lcmv.lambda       = '10%';
                cfg.lcmv.keepfilter = 'yes';
                cfg.keepleadfield = 'yes';
                
                dataSrc = ft_sourceanalysis(cfg, dataTL);
                
                saveFileName=strsplit(file_{1},'.mat');
                saveFileName=strsplit(saveFileName{1},filesep);
                saveFileName=saveFileName{end};
                
                disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep Addprefix nameROI '_' headmodelType '_' saveFileName '.mat'])
                save([mainpath filesep '..' filesep '6_EEG' filesep Addprefix nameROI '_' headmodelType '_' saveFileName '.mat'],'ROIpos','data','dataTL','dataSrc','-v7.3')
                disp('done.')
            end
        end
    end
end
if plotSource
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'avg.pow';
    cfg.maskparameter = cfg.funparameter;
    cfg.funcolorlim   = [0.0 1.2];
    cfg.opacitylim    = [0.0 1.2];
    cfg.opacitymap    = 'rampup';
    ft_sourceplot(cfg, dataSrc);
end

%%
exit
