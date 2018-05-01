% mainpath=['P:' filesep '3018037.01' filesep 'Experiment3.2_ERC' filesep 'tommys_folder' filesep 'fMRI_pipeline' filesep 'P31' filesep 'B_scripts'];
cd([mainpath filesep '..' filesep '4_retinotopy'])
disp('setting up environment...')
addpath(genpath([mainpath filesep '..' filesep '..' filesep 'toolboxes']))
disp('done.')

disp('loading data...')
filetouse=[mainpath filesep '..' filesep '2_coregistration' filesep 'fctgraymattercoreg.nii'];
if exist(filetouse,'file')==0
    unix(['gunzip -f -c ' filetouse '.gz >' filetouse]);
end
mask = niiload(filetouse,[],[],0);
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'results_analyzePRF_avg_all.mat'])
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'voxelindices.mat'])
newoverlaytemplate = mask;
hdr=load_nii_hdr(filetouse);
nii = load_untouch_nii(filetouse);
disp('done.')
%% Ang
ang_map=nii;
ang_map.img(nii.img>mask_threshold)=resultsall.ang;
save_untouch_nii(ang_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ang_map.nii']);
%% Ecc
ecc_map=nii;
ecc_map.img(nii.img>mask_threshold)=resultsall.ecc;
save_untouch_nii(ecc_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ecc_map.nii']);
%% Expt
expt_map=nii;
expt_map.img(nii.img>mask_threshold)=resultsall.expt;
save_untouch_nii(expt_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'expt_map.nii']);
%% rfsize
rfsize_map=nii;
rfsize_map.img(nii.img>mask_threshold)=resultsall.rfsize;
save_untouch_nii(rfsize_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'rfsize_map.nii']);
%% Xpos Ypos
degvisdeg=7;
cfactor = degvisdeg/86;

ecc_=resultsall.ecc;
ecc_(ecc_>86 | ecc_<0 | resultsall.R2<0)=NaN;
xpos = ecc_ .* cos(resultsall.ang./180.*pi) .* cfactor;
ypos = ecc_ .* sin(resultsall.ang./180.*pi) .* cfactor;

xpos_map=nii;
ind_=nii.img>mask_threshold;
xpos_map.img(ind_)=xpos;
xpos_map.img(~ind_)=NaN;
save_untouch_nii(xpos_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'xpos_map.nii']);

ypos_map=nii;
ypos_map.img(ind_)=ypos;
ypos_map.img(~ind_)=NaN;
save_untouch_nii(ypos_map,[mainpath filesep '..' filesep '4_retinotopy' filesep 'ypos_map.nii']);

%% cartesian map
theta=deg2rad(resultsall.ang(resultsall.R2>0));
rho=ones(size(theta));%rho=resultsall.ecc(resultsall.R2>0);
[x,y]=pol2cart(theta,rho);
scatter(x,y)

%%
disp('loading interpolated functionals...')
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'interpolatedTseries.mat']);
load([mainpath filesep '..' filesep '4_retinotopy' filesep 'images_downsampled.mat'])
disp('done.')

avgdata=1;
ana_add_string='';
if exist('avgdata','var')>0
    if avgdata
        datacomb={mean(cat(numel(size(data{1}))+1,data{:}),numel(size(data{1}))+1)};
        images={mean(cat(numel(size(images{1}))+1,images{:}),numel(size(images{1}))+1)};
        ana_add_string=[ana_add_string 'avg'];
        seedmode=struct('seedmode',[2]);
    end
end

res = [86 86];
resmx = max(res);
hrf=resultsall.options.hrf;
degs=resultsall.options.maxpolydeg;

[d,xx,yy]=makegaussian2d(resmx, 2,2,2,2);

stimulusPP={};
stimulus=images;
for p=1:length(stimulus)
  stimulusPP{p} = squish(stimulus{p},2)';  % this flattens the image so that the dimensionality is now frames x pixels
  stimulusPP{p} = [stimulusPP{p} p*ones(size(stimulusPP{p},1),1)];  % this adds a dummy column to indicate run breaks
end

modelfun = @(pp,dd) conv2run(posrect(pp(4)) * (dd*[vflatten(placematrix(zeros(res),makegaussian2d(resmx,pp(1),pp(2),abs(pp(3)),abs(pp(3)),xx,yy,0,0) / (2*pi*abs(pp(3))^2))); 0]) .^ posrect(pp(5)),hrf,dd(:,prod(res)+1));
polymatrix = {};
for p=1:length(degs)
  polymatrix{p} = projectionmatrix(constructpolynomialmatrix(size(data{p},2),0:degs(p)));
end

%%
degvisdeg=7;
cfactor = degvisdeg/86;

% Visualize the location of each voxel's pRF
figure; hold on;
results=resultsall;
set(gcf,'Units','points','Position',[100 100 400 400]);
cmap = jet(size(results.ang,1));

ecc_=resultsall.ecc;
ecc_(ecc_>86 | ecc_<0)=NaN;
xpos = ecc_ .* cos(resultsall.ang./180.*pi) .* cfactor;
ypos = ecc_ .* sin(resultsall.ang./180.*pi) .* cfactor;
ang = results.ang./180.*pi;
sd = results.rfsize .* cfactor;
set(scatter(xpos,ypos,5,'filled'),'CData',cmap);
drawrectangle(0,0,degvisdeg,degvisdeg,'k-');  % square indicating stimulus extent
axis([-degvisdeg degvisdeg -degvisdeg degvisdeg]);
straightline(0,'h','k-');       % line indicating horizontal meridian
straightline(0,'v','k-');       % line indicating vertical meridian
axis square;
set(gca,'XTick',-degvisdeg:2:degvisdeg,'YTick',-degvisdeg:2:degvisdeg);
xlabel('X-position (deg)');
ylabel('Y-position (deg)');

polar_label=linspace(0,2,21);

xpos = results.ecc .* cos(results.ang./180.*pi) .* cfactor;
ypos = results.ecc .* sin(results.ang./180.*pi) .* cfactor;
ang = results.ang./180.*pi;
sd = results.rfsize .* cfactor;
set(scatter(xpos,ypos,5,'filled'),'CData',cmap);
drawrectangle(0,0,degvisdeg,degvisdeg,'k-');  % square indicating stimulus extent
axis([-degvisdeg degvisdeg -degvisdeg degvisdeg]);
straightline(0,'h','k-');       % line indicating horizontal meridian
straightline(0,'v','k-');       % line indicating vertical meridian
axis square;
set(gca,'XTick',-degvisdeg:2:degvisdeg,'YTick',-degvisdeg:2:degvisdeg);
xlabel('X-position (deg)');
ylabel('Y-position (deg)');

polar_label=linspace(0,2,21);

testy=linspace(0,2,length(cmap));
testx=ones(1,length(cmap)).*degvisdeg;
yyaxis right
yticks(polar_label)
testy=linspace(0,2,length(cmap));
testx=ones(1,length(cmap)).*degvisdeg;
yyaxis right
yticks(polar_label)
testy=linspace(0,2,length(cmap));
testx=ones(1,length(cmap)).*degvisdeg;
yyaxis right
yticks(polar_label)
testy=linspace(0,2,length(cmap));
testx=ones(1,length(cmap)).*degvisdeg;
yyaxis right
yticks(polar_label)
scatter(testx,testy,'r.','CData',cmap)

%%
close all
ind_=xpos>(-degvisdeg/2) & xpos<(degvisdeg/2) & ypos>(-degvisdeg/2) & ypos<(degvisdeg/2);

num_to_cluster=100;

spacing=linspace(-degvisdeg/2,degvisdeg/2,numel(resultsall.ang)/num_to_cluster);
ang_new=resultsall.ang(ind_)./180.*pi;
[xq,yq] = meshgrid(spacing, spacing);
ang_new=wrapTo2Pi(ang_new);
%ang_new(ang_new<0)=-ang_new(ang_new<0);
%[~,I]=sort(ypos(ind_),'ascend');
%vq = griddata(xpos(ind_),ypos(ind_),I,xq,yq,'linear');
scatter(xpos,ypos,'CData',ang)
vq = griddata(xpos,ypos,ang,xq,yq,'linear');
figure
ypos = results.ecc .* sin(results.ang./180.*pi) .* cfactor;
ang = results.ang./180.*pi;
sd = results.rfsize .* cfactor;
set(scatter(xpos,ypos,5,'filled'),'CData',cmap);
drawrectangle(0,0,degvisdeg,degvisdeg,'k-');  % square indicating stimulus extent
axis([-degvisdeg degvisdeg -degvisdeg degvisdeg]);
straightline(0,'h','k-');       % line indicating horizontal meridian
straightline(0,'v','k-');       % line indicating vertical meridian
axis square;
set(gca,'XTick',-degvisdeg:2:degvisdeg,'YTick',-degvisdeg:2:degvisdeg);
xlabel('X-position (deg)');
ylabel('Y-position (deg)');

polar_label=linspace(0,2,21);

testy=linspace(0,2,length(cmap));
testx=ones(1,length(cmap)).*degvisdeg;
yyaxis right
yticks(polar_label)
scatter(testx,testy,'r.','CData',cmap)

%%
close all
ind_=xpos>(-degvisdeg/2) & xpos<(degvisdeg/2) & ypos>(-degvisdeg/2) & ypos<(degvisdeg/2);

num_to_cluster=100;

spacing=linspace(-degvisdeg/2,degvisdeg/2,numel(resultsall.ang)/num_to_cluster);
ang_new=resultsall.ang(ind_)./180.*pi;
[xq,yq] = meshgrid(spacing, spacing);
ang_new=wrapTo2Pi(ang_new);
%ang_new(ang_new<0)=-ang_new(ang_new<0);
%[~,I]=sort(ypos(ind_),'ascend');
%vq = griddata(xpos(ind_),ypos(ind_),I,xq,yq,'linear');
scatter(xpos,ypos,'CData',ang)
vq = griddata(xpos,ypos,ang,xq,yq,'linear');
figure
imagesc(vq);set(gca,'YDir','normal');hold on
colormap(jet)
%mesh(xq,yq,vq)

%%
cfactor = 10/86;

% Visualize the location of each voxel's pRF
figure; hold on;
results=resultsall;
imagesc(vq);set(gca,'YDir','normal');hold on
colormap(jet)
%mesh(xq,yq,vq)

%%
cfactor = 10/86;

% Visualize the location of each voxel's pRF
figure; hold on;
results=resultsall;
%mesh(xq,yq,vq)

%%
cfactor = 10/86;

% Visualize the location of each voxel's pRF
figure; hold on;
%mesh(xq,yq,vq)

%%
cfactor = 10/86;

% Visualize the location of each voxel's pRF
figure; hold on;
results=resultsall;
set(gcf,'Units','points','Position',[100 100 400 400]);
cmap = jet(size(results.ang,1));
for p=1:size(results.ang,1)
  xpos = results.ecc(p) * cos(results.ang(p)/180*pi) * cfactor;
  ypos = results.ecc(p) * sin(results.ang(p)/180*pi) * cfactor;
  ang = results.ang(p)/180*pi;
  sd = results.rfsize(p) * cfactor;
  h = drawellipse(xpos,ypos,ang,2*sd,2*sd);  % circle at +/- 2 pRF sizes
  set(h,'Color',cmap(p,:),'LineWidth',2);
  set(scatter(xpos,ypos,'r.'),'CData',cmap(p,:));
end
drawrectangle(0,0,10,10,'k-');  % square indicating stimulus extent
axis([-10 10 -10 10]);
straightline(0,'h','k-');       % line indicating horizontal meridian
straightline(0,'v','k-');       % line indicating vertical meridian
axis square;
set(gca,'XTick',-10:2:10,'YTick',-10:2:10);
xlabel('X-position (deg)');
ylabel('Y-position (deg)');


%% Which voxel should we inspect?  Let's inspect the second voxel.
vx = 2;

% For each run, collect the data and the model fit.  We project out polynomials
% from both the data and the model fit.  This deals with the problem of
% slow trends in the data.
datats = {};
modelts = {};

[~,vx]=max(resultsall.R2);

for p=1:length(datacomb)
  datats{p} =  polymatrix{p}*datacomb{p}(vx,:)';
  modelts{p} = polymatrix{p}*modelfun(resultsall.params(1,:,vx),stimulusPP{p});
end

% Visualize the results
figure; hold on;
set(gcf,'Units','points','Position',[100 100 1000 100]);
plot(cat(1,datats{:}),'r-');
plot(cat(1,modelts{:}),'b-');
straightline(300*(1:4)+.5,'v','g-');
xlabel('Time (s)');
ylabel('BOLD signal');
ax = axis;
axis([.5 1200+.5 ax(3:4)]);
title('Time-series data');

%%
exit
