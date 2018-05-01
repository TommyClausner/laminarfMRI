


addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
tvm_installOpenFmriAnalysisToolbox;

%%
tic;disp('doing boundary registration...')

configuration = [];
configuration.i_SubjectDirectory        = [mainpath filesep '..'];
configuration.i_FreeSurferFolder        = '0_freesurfer';
configuration.i_RegistrationVolume      = ['2_coregistration/' regvol];
configuration.i_DegreesOfFreedom        = 6;
configuration.i_Contrast                = 'T1';
configuration.o_Boundaries              = '2_coregistration/boundaries.mat';
configuration.o_CoregistrationMatrix    = '2_coregistration/matrix.mat';
configuration.o_RegisterDat             = '2_coregistration/bbregister.dat';

tvm_useBbregister(configuration);

load([mainpath filesep '..' filesep '2_coregistration' filesep 'matrix.mat']);
dlmwrite([mainpath filesep '..' filesep '2_coregistration' filesep 'transmat.txt'],coregistrationMatrix,'\t');
dlmwrite([mainpath filesep '..' filesep '2_coregistration' filesep 'transmatinv.txt'],inv(coregistrationMatrix),'\t');

disp(['done after ' num2str(toc) 's'])

tic;disp('creating boundary movie...')
configuration = [];
configuration.i_SubjectDirectory    = [mainpath filesep '..'];
configuration.i_ReferenceVolume     = ['2_coregistration/' regvol];
configuration.i_Boundaries          = {'2_coregistration/boundaries.mat'};
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
configuration.i_ReferenceVolume     = ['2_coregistration/' regvol];
configuration.i_Boundaries          = '2_coregistration/boundaries.mat';
configuration.i_MinimumVoxels       = 4;
configuration.i_MinimumVertices     = 100;
configuration.i_NeighbourSmoothing  = 0.1;
configuration.i_CuboidElements      = true;
configuration.i_Tetrahedra          = true;

configuration.o_Boundaries          = '2_coregistration/boundaries_rbr.mat';
configuration.o_DisplacementMap     = '2_coregistration/Displacement.nii';

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
configuration.i_ReferenceVolume     = ['2_coregistration/' regvol];
configuration.i_Boundaries          = {'2_coregistration/boundaries_rbr.mat'};
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
configuration.i_ReferenceVolume     = ['2_coregistration/' regvol];
configuration.i_Boundaries          = {'2_coregistration/boundaries.mat','2_coregistration/boundaries_rbr.mat'};
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

exit
