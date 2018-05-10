%%
% mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts'

addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
ft_defaults

%% create mesh

convertCoordSys=0;
showResult=0;

conductModel='BEM';

mri = ft_read_mri([mainpath filesep '..' filesep '0_freesurfer' filesep 'mri' filesep 'orig_nu.mgz']);

if convertCoordSys
    cfg = [];
    cfg.coordsys = 'ctf';
    mri = ft_volumerealign(cfg,mri);
    
    cfg = [];
    mri = ft_volumereslice(cfg,mri);
else
    mri.coordsys='ras';
end

cfg = [];
cfg.output    = {'brain','skull','scalp'};
cfg.scalpsmooth = 10;
mri = ft_volumesegment(cfg,mri);

cfg = [];
cfg.method = 'hexahedral';
cfg.shift  = 0.3; %% <0.5, is needed so elements are still convex
mesh = ft_prepare_mesh(cfg,mri);

cfg = [];
cfg.tissue={'brain','skull','scalp'};
cfg.method = 'projectmesh';
cfg.numvertices = [1000 2000 3000];
mesh_surf = ft_prepare_mesh(cfg,mri);

if showResult
    
    ft_plot_mesh(mesh_surf)
    
end


switch conductModel
    case 'FEM'
        cfg = [];
        cfg.method = 'simbio';
        %cfg.conductivity = [0.33 0.14 1.79 0.01 0.43];   % order follows mesh.tissyelabel
        cfg.conductivity = [0.43 0.01 0.33];
        headmodel = ft_prepare_headmodel(cfg,mesh);
    case 'BEM'
        setenv('PATH', ['/opt/openmeeg/2.2.0/bin:' getenv('PATH')]);
        setenv('LD_LIBRARY_PATH', ['/opt/openmeeg/2.2.0/lib:' getenv('LD_LIBRARY_PATH')]);
        
        cfg = [];
        cfg.method = 'openmeeg'; %openmeeg prefereable, should be available on the cluster
        cfg.conductivity = [0.43 0.01 0.33];   % order follows mesh.tissyelabel
        headmodel = ft_prepare_headmodel(cfg,mesh_surf);
end

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel.mat'],'mri','mesh','mesh_surf','headmodel','-v7.3')
disp('done.')

%%
exit