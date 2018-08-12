function  all_moves =  fun_make_rp2(moves)
%% adapted from Rene Scheeringa (2018, DCCN)
if size(moves,1)==6 && size(moves,2)~=6
    moves=moves';
end
sqx = moves(:,1).^2;
sqy = moves(:,2).^2;
sqz = moves(:,3).^2;
sq_x_rot = moves(:,4).^2;
sq_y_rot = moves(:,5).^2;
sq_z_rot = moves(:,6).^2;

%first derivative
%[px py] = gradient(moves);
py = diff(moves);
der1x =  [0; py(:,1)];
der1y =  [0; py(:,2)];
der1z =  [0; py(:,3)];
der1x_rot =  [0; py(:,4)];
der1y_rot =  [0; py(:,5)];
der1z_rot =  [0; py(:,6)];

%spin history effects   %I'm not sure you should include
%this in addition to the above parameters, you need to see
%how correlated the spin-hist effects are to the other
%variables.
spin_hist = [zeros(1,6);moves(1:end-1,:)];
spinx = spin_hist(:,1); 
spiny = spin_hist(:,2);
spinz = spin_hist(:,3);
spinx_rot = spin_hist(:,4);
spiny_rot = spin_hist(:,5);
spinz_rot = spin_hist(:,6);

all_moves = horzcat(moves,sqx,sqy, sqz,...
sq_x_rot,sq_y_rot,sq_z_rot,...
der1x ,der1y, der1z, der1x_rot,der1y_rot, der1z_rot,...
spinx, spiny,spinz,spinx_rot,spiny_rot,spinz_rot); 
