%%
% mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts'

addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
ft_defaults

%% Electrode registration
load([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'])
sensfile=dir([mainpath filesep '..' filesep 'rawData' filesep 'electrodes' filesep 'polhemus' filesep '*.pos']);
sens = ft_read_sens([sensfile.folder filesep sensfile.name]);
sens = ft_convert_units(sens,'mm');
cfg = [];
cfg.method = 'interactive';
cfg.headshape = mesh_surf(3);
sens = ft_electroderealign(cfg,sens);

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'sens.mat'],'sens','-v7.3')
disp('done.')

%%
exit