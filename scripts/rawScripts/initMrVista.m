addpath(genpath(['mainpath filesep '..' filesep '..' filesep toolboxes']))

cd([mainpath '/../2_coregistration'])
vistaRootPath
if ~exist('mrSESSION.mat','file')
    mrInit
end
mrVista

transmat = mrSESSION.alignment;
transmatinv = inv(transmat);
dlmwrite('transmat.txt',transmat,'delimiter','\t')
dlmwrite('transmatinv.txt',transmatinv,'delimiter','\t')

movefile('transmat.txt','transmat.mat')
movefile('transmatinv.txt','transmatinv.mat')
