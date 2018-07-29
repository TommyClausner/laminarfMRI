%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'fieldtrip'])
ft_defaults

%% create mesh

if ~exist('conductModel','var')
    conductModel='FEM';
end
convertCoordSys=0;
showResult=0;

mri = ft_read_mri([mainpath filesep '..' filesep '0_freesurfer' filesep 'mri' filesep 'orig_nu.mgz']);

if convertCoordSys
    cfg = [];
    cfg.coordsys = 'ctf';
    mri = ft_volumerealign(cfg,mri);
    
    cfg = [];
    mri = ft_volumereslice(cfg,mri);
else
    mri.coordsys='ras';
    cfg = [];
    mri = ft_volumereslice(cfg,mri);
end

switch conductModel
    case 'FEM'
        
        cfg = [];
        cfg.output    = {'gray','white','csf','skull','scalp'};
        cfg.scalpsmooth = 10;
        mri = ft_volumesegment(cfg,mri);
        
        cfg = [];
        cfg.method = 'hexahedral';
        cfg.shift  = 0.3; %% <0.5, is needed so elements are still convex
        mesh = ft_prepare_mesh(cfg,mri);
        
        cfg = [];
        cfg.method = 'simbio';
        cfg.conductivity = [0.33 0.14 1.79 0.01 0.43];
        headmodel = ft_prepare_headmodel(cfg,mesh);
    case 'BEM'
        
        cfg = [];
        cfg.output    = {'brain','skull','scalp'};
        cfg.scalpsmooth = 10;
        mri = ft_volumesegment(cfg,mri);
        
        cfg = [];
        cfg.tissue={'brain','skull','scalp'};
        cfg.method = 'projectmesh';
        cfg.numvertices = [1000 2000 3000];
        mesh = ft_prepare_mesh(cfg,mri);
        
        setenv('PATH', ['/opt/openmeeg/2.2.0/bin:' getenv('PATH')]);
        setenv('LD_LIBRARY_PATH', ['/opt/openmeeg/2.2.0/lib:' getenv('LD_LIBRARY_PATH')]);
        
        cfg = [];
        cfg.method = 'openmeeg'; %openmeeg prefereable, should be available on the cluster
        cfg.conductivity = [0.33 0.01 0.43];   % order follows mesh.tissyelabel
        headmodel = ft_prepare_headmodel(cfg,mesh);
        
end

if showResult
    ft_plot_mesh(mesh, 'surfaceonly', 'yes')
end

disp(['saving data to ' mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' conductModel '.mat'])
save([mainpath filesep '..' filesep '6_EEG' filesep 'headmodel_' conductModel '.mat'],'mri','mesh','headmodel','-v7.3')
disp('done.')

%%
exit
