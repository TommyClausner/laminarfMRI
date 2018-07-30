%%
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end

addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'OpenFmriAnalysis'])
addpath([mainpath filesep '..' filesep '..' filesep 'toolboxes' filesep 'spm12'])
tvm_installOpenFmriAnalysisToolbox;

%%
tic;disp('doing boundary registration...')

configuration = [];
configuration.i_SubjectDirectory        = [mainpath filesep '..'];
configuration.i_FreeSurferFolder        = '0_freesurfer';
configuration.i_RegistrationVolume      = ['3_coregistration/' regvol];
configuration.i_DegreesOfFreedom        = 6;
configuration.i_Contrast                = 'T1';
configuration.o_Boundaries              = '3_coregistration/boundaries.mat';
configuration.o_CoregistrationMatrix    = '3_coregistration/matrix.mat';
configuration.o_RegisterDat             = '3_coregistration/bbregister.dat';

tvm_useBbregister(configuration);

load([mainpath filesep '..' filesep '3_coregistration' filesep 'matrix.mat']);
dlmwrite([mainpath filesep '..' filesep '3_coregistration' filesep 'transmat.txt'],coregistrationMatrix,'\t');
dlmwrite([mainpath filesep '..' filesep '3_coregistration' filesep 'transmatinv.txt'],inv(coregistrationMatrix),'\t');

disp(['done after ' num2str(toc) 's'])

tic;disp('creating boundary movie...')
configuration = [];
configuration.i_SubjectDirectory    = [mainpath filesep '..'];
configuration.i_ReferenceVolume     = ['3_coregistration/' regvol];
configuration.i_Boundaries          = {'3_coregistration/boundaries.mat'};
configuration.i_Axis                = 'horizontal';
configuration.i_FramesPerSecond     = 6;
configuration.i_ContourColors       = {'r', 'r', 'g', 'g'};
configuration.o_RegistrationMovie   = 'C_miscResults/RegistrationMovie.avi';

try
    tvm_volumeWithBoundariesToMovie(configuration);
catch
    tvm_volumeWithBoundariesToMovie(configuration);
end
disp(['done after ' num2str(toc) 's'])

%%
tic;disp('doing recursive boundary registration...')
configuration = [];
configuration.i_SubjectDirectory        = [mainpath filesep '..'];
configuration.i_ReferenceVolume     = ['3_coregistration/' regvol];
configuration.i_Boundaries          = '3_coregistration/boundaries.mat';
configuration.i_MinimumVoxels       = 4;
configuration.i_MinimumVertices     = 100;
configuration.i_NeighbourSmoothing  = 0.1;
configuration.i_CuboidElements      = true;
configuration.i_Tetrahedra          = true;

configuration.o_Boundaries          = '3_coregistration/boundaries_rbr.mat';
configuration.o_DisplacementMap     = '3_coregistration/Displacement.nii';

registrationConfiguration = [];
registrationConfiguration.ReverseContrast       = false;
registrationConfiguration.Clamp                 = [0.4, 3];
registrationConfiguration.ContrastMethod        = 'average'; %'gradient'
registrationConfiguration.OptimisationMethod    = 'GreveFischl';
registrationConfiguration.Mode                  = 'syty';

tvm_recursiveBoundaryRegistration(configuration,registrationConfiguration);

disp(['done after ' num2str(toc) 's'])

tic;disp('creating boundary movie...')
configuration = [];
configuration.i_SubjectDirectory    = [mainpath filesep '..'];
configuration.i_ReferenceVolume     = ['3_coregistration/' regvol];
configuration.i_Boundaries          = {'3_coregistration/boundaries_rbr.mat'};
configuration.i_Axis                = 'horizontal';
configuration.i_FramesPerSecond     = 6;
configuration.i_ContourColors       = {'r', 'r', 'g', 'g'};
configuration.o_RegistrationMovie   = 'C_miscResults/RegistrationMovie_rbr.avi';

try
    tvm_volumeWithBoundariesToMovie(configuration);
catch
    tvm_volumeWithBoundariesToMovie(configuration);
end
disp(['done after ' num2str(toc) 's'])

tic;disp('creating boundary movie...')
configuration = [];
configuration.i_SubjectDirectory    = [mainpath filesep '..'];
configuration.i_ReferenceVolume     = ['3_coregistration/' regvol];
configuration.i_Boundaries          = {'3_coregistration/boundaries.mat','3_coregistration/boundaries_rbr.mat'};
configuration.i_Axis                = 'horizontal';
configuration.i_FramesPerSecond     = 6;
configuration.i_ContourColors       = {'r', 'r', 'g', 'g'};
configuration.o_RegistrationMovie   = 'C_miscResults/RegistrationMovie_both.avi';

try
    tvm_volumeWithBoundariesToMovie(configuration);
catch
    tvm_volumeWithBoundariesToMovie(configuration);
end
disp(['done after ' num2str(toc) 's'])
%%
exit
