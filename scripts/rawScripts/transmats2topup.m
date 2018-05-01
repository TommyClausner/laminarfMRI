

addpath(genpath(mainpath))

path_=transmatpath;

if ~exist('inv_','var')
inv_=0;
end

mkdir([path_ filesep 'topupformat'])
fcont=dir(path_);
fcont([fcont.isdir])=[];

for n={fcont.name}
    [rotation,translation] = tc_transmat2vec([path_ filesep n{1}],inv_);
    topupformat=[translation,rotation];
    dlmwrite([path_ filesep 'topupformat' filesep n{1} '.txt'],topupformat,'delimiter','\t','precision','%.6f')
end
