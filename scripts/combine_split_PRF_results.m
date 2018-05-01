
% mainpath=['P:' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];

disp('combining PRF results...')

fields={'ang',[],'ecc',[],'expt',[],'rfsize',[],'R2',[],'gain',[],...
    'resnorms',[],'numiters',[],'meanvol',[],'noisereg',[],'params',[],'options',[]};

resultsall=struct(fields{:});
for n=1:numparts
    load([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_part_' num2str(n) '_of_' num2str(numparts) '.mat'])
    
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
%%
exit