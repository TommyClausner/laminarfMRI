addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
tvm_installOpenFmriAnalysisToolbox;
%%
configuration = [];
configuration.i_SubjectDirectory = mainpath;
configuration.i_LevelSet            = '5_laminar/brain.levels.nii';
configuration.o_ObjFile             = '5_laminar/LayersObj.obj';
tvm_levelSetToObj(configuration)

%%
numberOfLayers = 3;
configuration = [];
configuration.i_SubjectDirectory = mainpath;
objFiles                            = strsplit(sprintf('5_laminar/LayersObj%02d.obj\n', 0:numberOfLayers));
configuration.i_ObjFile             = objFiles(1:end - 1);
configuration.o_BoundaryFile        = '5_laminar/Layers.mat';
tvm_objToBoundary(configuration)
%%

configuration = [];
configuration.i_SubjectDirectory = mainpath;
configuration.i_Boundaries          = '5_laminar/Layers.mat';
configuration.i_Axis                = 'horizontal';
configuration.i_FramesPerSecond     = 6;
configuration.i_ContourColors       = {[0 0 0],[1 0 0],[0 1 0],[0 0 1]};
configuration.i_ReferenceVolume     = ['1_realignment/' regvol '.nii'];
%configuration.i_RegionOfInterest    = {'5_laminar/rhV1mask_layers.nii', '5_laminar/lhV1mask_layers.nii'};
configuration.o_RegistrationMovie   = 'C_miscResults/Layers.avi';
try
    tvm_volumeWithBoundariesToMovie(configuration);
catch
    tvm_volumeWithBoundariesToMovie(configuration);   
end
%%
exit