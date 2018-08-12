%% adapted from Rene Scheeringa (2018, DCCN)
if ~exist('mainpath','var')
    mainpath='~/subjects/SXX/B_scripts';
    cd(mainpath)
end

%%
centr=1; %centred or not centred
templ=3; %template type 1:block, 2:other blokcs (3); 3: all blocks (4)

%% load feature signals
load([mainpath filesep '..' filesep '7_results' filesep 'feat_sigs_centr' num2str(centr) '_templ' num2str(templ) '.mat'])
%% Load regressors
load([mainpath filesep '..' filesep '6_EEG' filesep 'convolved_eeg_task_regressors.mat']); 

%% load compartment/dropoff signals
load([mainpath filesep '..' filesep '7_results' filesep 'compregs.mat']);

%% load realignment paramaters
load([mainpath filesep '..' filesep '7_results' filesep 'RP.mat']);

%% make low-pass filter signals
freq=0.006;
filt=make_filter_regs(freq);
%% correlate stuff
CF.blok1=[nuisreg_conv.b1.task(:,2:end) rtreg_conv.b1.task(:,1) rtreg_conv.b1.par T1_white' squeeze(RP_all(:,:,1)) filt.regs ones(240,1)];
CF.blok2=[nuisreg_conv.b2.task(:,2:end) rtreg_conv.b2.task(:,1) rtreg_conv.b2.par T1_white' squeeze(RP_all(:,:,2)) filt.regs ones(240,1)];
CF.blok3=[nuisreg_conv.b3.task(:,2:end) rtreg_conv.b3.task(:,1) rtreg_conv.b3.par T1_white' squeeze(RP_all(:,:,3)) filt.regs ones(240,1)];
CF.blok4=[nuisreg_conv.b4.task(:,2:end) rtreg_conv.b4.task(:,1) rtreg_conv.b4.par T1_white' squeeze(RP_all(:,:,4)) filt.regs ones(240,1)];%wm_sig_res(:,4) 

D1=[task_conv.L.b1.task task_conv.R.b1.task];
D2=[task_conv.L.b2.task task_conv.R.b2.task];
D3=[task_conv.L.b3.task task_conv.R.b3.task];
D4=[task_conv.L.b4.task task_conv.R.b4.task];


hem={'lh','rh'};
area={'V1','V2','V3'};

for h=1:length(hem)
    for a = 1:length(area)
        
        eval(['signals=feat_sigs.' hem{h}, '.' area{a} ';']);
        
        for i=1:15
            
            
            R{h,a}.B1{i}=regstats((squeeze(signals(i,:,1)))',[D1 CF.blok1(:,1:end-1)],  'linear');
            R{h,a}.B2{i}=regstats((squeeze(signals(i,:,2)))',[D2 CF.blok2(:,1:end-1)],  'linear');
            R{h,a}.B3{i}=regstats((squeeze(signals(i,:,3)))',[D3 CF.blok3(:,1:end-1)],  'linear');
            R{h,a}.B4{i}=regstats((squeeze(signals(i,:,4)))',[D4 CF.blok4(:,1:end-1)],  'linear');
            
            bets{h,a}=[R{h,a}.B1{i}.tstat.beta([2 3]) R{h,a}.B2{i}.tstat.beta([2 3]) R{h,a}.B3{i}.tstat.beta([2 3]) R{h,a}.B4{i}.tstat.beta([2 3])];
            stds{h,a}=[R{h,a}.B1{i}.tstat.se([2 3]).*sqrt(R{h,a}.B1{i}.tstat.dfe)...
                R{h,a}.B2{i}.tstat.se([2 3]).*sqrt(R{h,a}.B2{i}.tstat.dfe)...
                R{h,a}.B3{i}.tstat.se([2 3]).*sqrt(R{h,a}.B3{i}.tstat.dfe)...
                R{h,a}.B4{i}.tstat.se([2 3]).*sqrt(R{h,a}.B4{i}.tstat.dfe)...
                ];
            dfs{h,a}=[R{h,a}.B1{i}.tstat.dfe R{h,a}.B2{i}.tstat.dfe R{h,a}.B3{i}.tstat.dfe R{h,a}.B4{i}.tstat.dfe];
            
            R{h,a}.TC{i}=sum(bets{h,a},2)./(sum(stds{h,a},2)./sqrt(sum(dfs{h,a})));
            B_combined{h,a}(i,[1 2])= sum(bets{h,a},2);
            se_combined{h,a}(i,[1 2])= (sum(stds{h,a},2)./sqrt(sum(dfs{h,a})));
            T_combined{h,a}(i,[1 2])=sum(bets{h,a},2)./(sum(stds{h,a},2)./sqrt(sum(dfs{h,a})));
            
        end
    end
end
% 


D1=[task_conv.L.b1.task task_conv.R.b1.task alpha_conv.L.b1.par alpha_conv.R.b1.par beta_conv.L.b1.par beta_conv.R.b1.par gamma_conv.L.b1.par gamma_conv.R.b1.par];
D2=[task_conv.L.b2.task task_conv.R.b2.task alpha_conv.L.b2.par alpha_conv.R.b2.par beta_conv.L.b2.par beta_conv.R.b2.par gamma_conv.L.b2.par gamma_conv.R.b2.par];
D3=[task_conv.L.b3.task task_conv.R.b3.task alpha_conv.L.b3.par alpha_conv.R.b3.par beta_conv.L.b3.par beta_conv.R.b3.par gamma_conv.L.b3.par gamma_conv.R.b3.par];
D4=[task_conv.L.b4.task task_conv.R.b4.task alpha_conv.L.b4.par alpha_conv.R.b4.par beta_conv.L.b4.par beta_conv.R.b4.par gamma_conv.L.b4.par gamma_conv.R.b4.par];


for h=1:length(hem)
    for a = 1:length(area)
        
        eval(['signals=feat_sigs.' hem{h}, '.' area{a} ';']);
        
        for i=1:15
            
            
            R{h,a}.B1{i}=regstats((squeeze(signals(i,:,1)))',[D1 CF.blok1(:,1:end-1)],  'linear');
            R{h,a}.B2{i}=regstats((squeeze(signals(i,:,2)))',[D2 CF.blok2(:,1:end-1)],  'linear');
            R{h,a}.B3{i}=regstats((squeeze(signals(i,:,3)))',[D3 CF.blok3(:,1:end-1)],  'linear');
            R{h,a}.B4{i}=regstats((squeeze(signals(i,:,4)))',[D4 CF.blok4(:,1:end-1)],  'linear');
            
            bets{h,a}=[R{h,a}.B1{i}.tstat.beta(2:9) R{h,a}.B2{i}.tstat.beta(2:9) R{h,a}.B3{i}.tstat.beta(2:9) R{h,a}.B4{i}.tstat.beta(2:9)];
            stds{h,a}=[R{h,a}.B1{i}.tstat.se(2:9).*sqrt(R{h,a}.B1{i}.tstat.dfe)...
                R{h,a}.B2{i}.tstat.se(2:9).*sqrt(R{h,a}.B2{i}.tstat.dfe)...
                R{h,a}.B3{i}.tstat.se(2:9).*sqrt(R{h,a}.B3{i}.tstat.dfe)...
                R{h,a}.B4{i}.tstat.se(2:9).*sqrt(R{h,a}.B4{i}.tstat.dfe)...
                ];
            dfs{h,a}=[R{h,a}.B1{i}.tstat.dfe R{h,a}.B2{i}.tstat.dfe R{h,a}.B3{i}.tstat.dfe R{h,a}.B4{i}.tstat.dfe];
            
            R{h,a}.TC{i}=sum(bets{h,a},2)./(sum(stds{h,a},2)./sqrt(sum(dfs{h,a})));
            B_combined{h,a}(i,1:8)= sum(bets{h,a},2);
            se_combined{h,a}(i,1:8)= (sum(stds{h,a},2)./sqrt(sum(dfs{h,a})));
            T_combined{h,a}(i,1:8)=sum(bets{h,a},2)./(sum(stds{h,a},2)./sqrt(sum(dfs{h,a})));
            
            %Ts(i,:,:)=[R.B1{1, i}.tstat.t(2:9) R.B2{1, i}.tstat.t(2:9) R.B3{1, i}.tstat.t(2:9) R.B4{1, i}.tstat.t(2:9)];
        end
    end
end
