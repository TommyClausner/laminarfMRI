%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'OpenFmriAnalysis'])
tvm_installOpenFmriAnalysisToolbox

%%
if ~exist('numLayers','var')
    numLayers=3;
end
if ~exist('revol','var')
    revol='MCTemplateThrCont';
end

mainpath = [mainpath filesep '..'];

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