%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults

%% Electrode registration

custom_elecs = 0;

if custom_elecs
    
    filetouse=[mainpath filesep '..' filesep 'rawData' filesep 'electrodes' filesep 'photogrammetry' filesep 'electrodes.mat'];
    load(filetouse)
    
    sens=[]
    sens.chanpos = Electrodes.MRI.points;
    sens.chantype = arrayfun(@(x) {'eeg'}, 1:size(Electrodes.MRI.points,1))';
    sens.chanunit = arrayfun(@(x) {'V'}, 1:size(Electrodes.MRI.points,1))';
    sens.elecpos = Electrodes.MRI.points;
    sens.label = Electrodes.MRI.label';
    sens.unit = 'mm'
    
    disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
    save([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'sens','-v7.3')
    disp('done.')
    
    exit
end

headmodelType='FEM';

load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' headmodelType '.mat'])
sensfile=dir([mainpath filesep '..' filesep 'rawData' filesep 'electrodes' filesep 'polhemus' filesep '*.pos']);
sens = ft_read_sens([sensfile.folder filesep sensfile.name]);
sens = ft_convert_units(sens,'mm');
cfg = [];
cfg.method = 'interactive';
cfg.headshape = mesh(end);
sens = ft_electroderealign(cfg,sens);

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'sens','-v7.3')
disp('done.')

%%
exit