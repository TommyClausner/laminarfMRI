function nuis_reg=fun_conv_nuis_reg(reg, regnames)
%% Adapted from Rene Scheeringa (2018, DCCN)
%reg(:,3)=zscore(reg(:,3));

b1_ind=1;
b2_ind=1;
b3_ind=1;
b4_ind=1;

for i=1:length(reg)
    trls=reg{i}(:,4)==1;
    if sum(trls)>0
        b1_regs{b1_ind}=reg{i}(trls,1:3);
        b1_regnames{b1_ind}=regnames{i};
        b1_ind=b1_ind+1;
    end
    
    trls=reg{i}(:,4)==2;
    if sum(trls)>0
        b2_regs{b2_ind}=reg{i}(trls,1:3);
        b2_regnames{b2_ind}=regnames{i};
        b2_ind=b2_ind+1;
    end
    
    trls=reg{i}(:,4)==3;
    if sum(trls)>0
        b3_regs{b3_ind}=reg{i}(trls,1:3);
        b3_regnames{b3_ind}=regnames{i};
        b3_ind=b3_ind+1;
    end
    
    trls=reg{i}(:,4)==4;
    if sum(trls)>0
        b4_regs{b4_ind}=reg{i}(trls,1:3);
        b4_regnames{b4_ind}=regnames{i};
        b4_ind=b4_ind+1;
    end
end

nuis_reg.b1=make_reg(b1_regs);
nuis_reg.b1.names=b1_regnames;

nuis_reg.b2=make_reg(b2_regs);
nuis_reg.b2.names=b2_regnames;

nuis_reg.b3=make_reg(b3_regs);
nuis_reg.b3.names=b3_regnames;

nuis_reg.b4=make_reg(b4_regs);
nuis_reg.b4.names=b4_regnames;

