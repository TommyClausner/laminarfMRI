%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';    
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'tc_functions']))
ft_defaults

%% Electrode registration

janus3D_elecs = 1;

if janus3D_elecs
    
    filetouse=[mainpath filesep '..' filesep 'rawData' filesep 'electrodes' filesep 'photogrammetry' filesep 'electrodes.mat'];
    sens=tc_janus3D2sens(filetouse,1:63);
    
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
