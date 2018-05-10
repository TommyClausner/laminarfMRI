%% Creating of mesh and Fem model
data_path = 'Data/';
filename  = 'orig.mgz';

mri = ft_read_mri([data_path,filename]);

cfg = [];
cfg.coordsys = 'ctf';
mri_realign = ft_volumerealign(cfg,mri);

cfg = [];
mri_reslice = ft_volumereslice(cfg,mri_realign);

cfg = [];
cfg.spmversion = 'spm8';
cfg.output    = {'brain','skull','scalp'};
cfg.scalpsmooth = 10;
mri_segmented = ft_volumesegment(cfg,mri_reslice);

cfg = [];
cfg.method = 'hexahedral';
cfg.shift  = 0.3; %% <0.5, is needed so elements are still convex
mesh = ft_prepare_mesh(cfg,mri_segmented);
%%
cfg = [];
cfg.tissue={'brain','skull','scalp'};
cfg.method = 'projectmesh';
cfg.numvertices = [1000 2000 3000];
mesh_surf = ft_prepare_mesh(cfg,mri_segmented);
ft_plot_mesh(mesh_surf)
%%
cfg = [];
cfg.method = 'simbio';
cfg.conductivity = [0.33 0.14 1.79 0.01 0.43];   % order follows mesh.tissyelabel
headmodel = ft_prepare_headmodel(cfg,mesh);


cfg = [];
cfg.method = 'dipoli'; %openmeeg prefereable, should be available on the cluster
cfg.conductivity = [0.33 0.01 0.43];   % order follows mesh.tissyelabel
headmodel = ft_prepare_headmodel(cfg,mesh_surf);

%% Electrode registration
filename  = 'P31.pos';
sens = ft_read_sens([data_path,filename]);
sens = ft_convert_units(sens,'mm');
cfg = [];
cfg.method = 'interactive';
cfg.headshape = mesh_surf(3);
sens = ft_electroderealign(cfg,sens);

%% headmodel

cfg = [];
[headmodel_prep,sens_prep] = ft_prepare_vol_sens(headmodel,sens);
save headmodel_prep headmodel_prep
save sens_prep sens_prep

%% sourcemodel
%first qsub_postscript, usses freesurfer and workbench to create
%sourcemodel
% now we only need to load the workbench sorucemodel

% IMPORTANT NOTE remove gifti funciton form Washington-University toolbox
% folder
pathname = ['Data/'];
subjname = 'freesurfer';
datapath = fullfile(pathname,subjname,'/workbench');
filename = fullfile(datapath,[subjname,'.L.midthickness.32k_fs_LR.surf.gii']);
sourcemodel = ft_read_headshape({filename, strrep(filename, '.L.', '.R.')});

save sourcemodel sourcemodel

