
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
tvm_installOpenFmriAnalysisToolbox;
%%
% numLayers = 3;
% revol = MCTemplateThrCont

mainpath = [mainpath filesep '..']

numberOfLayers = numLayers;
configuration = [];
configuration.i_SubjectDirectory    = mainpath;

configuration.i_Boundaries      = '2_coregistration/boundaries.mat';
configuration.o_ObjWhite        = '5_laminar/?h.white.reg.obj';
configuration.o_ObjPial         = '5_laminar/?h.pial.reg.obj';

configuration.i_ReferenceVolume = ['2_coregistration/' regvol '.nii'];
configuration.o_SdfWhite        = '5_laminar/?h.white.sdf.nii';
configuration.o_SdfPial         = '5_laminar/?h.pial.sdf.nii';
configuration.o_White           = '5_laminar/brain.white.sdf.nii';
configuration.o_Pial            = '5_laminar/brain.pial.sdf.nii';

configuration.o_Gradient       	= '5_laminar/brain.gradient.nii';
configuration.o_Curvature     	= '5_laminar/brain.curvature.nii';

configuration.i_Levels          = linspace(0,1,numberOfLayers+1);
configuration.o_LaplacePotential= '5_laminar/LaplacePotential.nii';
configuration.o_LevelSet        = '5_laminar/brain.levels.nii';
configuration.o_Layering        = '5_laminar/brain.layers.nii';

tvm_layerPipeline(configuration)

%%
exit