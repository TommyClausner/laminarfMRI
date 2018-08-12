function feat_sigs=fun_template_fit(centr,templ,reg,hem, Templates, ROI,CF)
%% adapted from Rene Scheeringa (2018, DCCN)
%centr=1; centred or not centred
%templ=2; template type 1:block, 2:other blokcs (3); 3: all blocks (4)
%reg='V1'; regions
%hem='lh'; hemisphere
%ROI:region of interest signal

%eval([ 'ROI = data_sel.' hem '.' reg ';']);


if centr==1
    c='_centred';
else
    c='';
end

if templ == 1
T1='B1';T2='B2';T3='B3';T4='B4';
elseif templ == 2
    T1='B234';T2='B134';T3='B124';T4='B123';
elseif templ == 3
    T1='B1234';T2='B1234';T3='B1234';T4='B1234';
end

if centr==1
    eval( ['templ_B1= [Templates.' hem  '.' reg '.L_' T1 c '; Templates.' hem  '.' reg '.R_' T1 c '; Templates.' hem  '.' reg '.layer_prob' '];']);
    eval( ['templ_B2= [Templates.' hem  '.' reg '.L_' T2 c '; Templates.' hem  '.' reg '.R_' T2 c '; Templates.' hem  '.' reg '.layer_prob' '];']);
    eval( ['templ_B3= [Templates.' hem  '.' reg '.L_' T3 c '; Templates.' hem  '.' reg '.R_' T3 c '; Templates.' hem  '.' reg '.layer_prob' '];']);
    eval( ['templ_B4= [Templates.' hem  '.' reg '.L_' T4 c '; Templates.' hem  '.' reg '.R_' T4 c '; Templates.' hem  '.' reg '.layer_prob' '];']);
    dimord = 'leftOr_rightOr_prob';
else
    eval( ['templ_B1= [Templates.' hem  '.' reg '.L_' T1 c '; Templates.' hem  '.' reg '.R_' T1 c '];']);
    eval( ['templ_B2= [Templates.' hem  '.' reg '.L_' T2 c '; Templates.' hem  '.' reg '.R_' T2 c '];']);
    eval( ['templ_B3= [Templates.' hem  '.' reg '.L_' T3 c '; Templates.' hem  '.' reg '.R_' T3 c '];']);
    eval( ['templ_B4= [Templates.' hem  '.' reg '.L_' T4 c '; Templates.' hem  '.' reg '.R_' T4 c '];']);
    dimord = 'leftOr_rightOr';
end

CFB1=CF.blok1\ROI(:,:,1)';
CFB2=CF.blok2\ROI(:,:,2)';
CFB3=CF.blok3\ROI(:,:,3)';
CFB4=CF.blok4\ROI(:,:,4)';

ROI_res(:,:,1) = zscore(ROI(:,:,1)-(CF.blok1*CFB1)',0,2);
ROI_res(:,:,2) = zscore(ROI(:,:,2)-(CF.blok2*CFB2)',0,2);
ROI_res(:,:,3) = zscore(ROI(:,:,3)-(CF.blok3*CFB3)',0,2);
ROI_res(:,:,4) = zscore(ROI(:,:,4)-(CF.blok4*CFB4)',0,2);

for i=1:240
    feat_sigs(:,i,1)=templ_B1'\ROI_res(:,i,1);
    feat_sigs(:,i,2)=templ_B2'\ROI_res(:,i,2);
    feat_sigs(:,i,3)=templ_B3'\ROI_res(:,i,3);
    feat_sigs(:,i,4)=templ_B4'\ROI_res(:,i,4);
end
