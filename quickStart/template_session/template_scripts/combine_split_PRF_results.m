
%%
if ~exist('mainpath','var')
    mainpath='/project/3018037.01/Experiment3.2_ERC/tommys_folder/fMRI_pipeline/P312/B_scripts';
    cd(mainpath)
end

%%
disp('combining PRF results...')

fields={'ang',[],'ecc',[],'expt',[],'rfsize',[],'R2',[],'gain',[],...
    'resnorms',[],'numiters',[],'meanvol',[],'noisereg',[],'params',[],'options',[]};

resultsall=struct(fields{:});
for n=1:numparts
    load([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_part_' num2str(n) '_of_' num2str(numparts) '_.mat'])
    
    for m=1:2:length(fields)-4
        eval(['resultsall.' fields{m} '=[resultsall.' fields{m} ';results.'  fields{m} ' ];']);
    end
    resultsall.params=cat(3,resultsall.params,results.params);
end
resultsall.options=results.options;

load([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices'])

resultsall.options.vxs=ind';

save([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_all.mat'],'resultsall','-v7.3')
disp('done.')
delete([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_part_*_of_*.mat']);
%%
exit
