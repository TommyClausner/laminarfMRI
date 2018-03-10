function [axang,trans] = tc_transmat2vec(R)
% #### hacked by Tommy ####
% original function is the MATLAB function "rotm2axang.m" from the robotics
% toolbox
%
% takes dlm-readable filename or 4x4 matrix as input
%
% Please check beforehand if the matrix is ortho-normal
%
% example: 	[axang,trans] = tc_transmat2vec('my_matrix.txt')
% example 2:	axang = tc_transmat2vec([1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1])
%
% axang 1 x 3 matrix giving the the respective rotation around x, y, z axis
% trans 1 x 3 matrix giving the the respective translation along x, y, z axis

if ischar(R)
R = dlmread(R);
end
trans=R(1:3,4)';
R(:,4)=[];
R(4,:)=[];
% Compute theta
theta = real(acos(complex((1/2)*(R(1,1,:)+R(2,2,:)+R(3,3,:)-1))));

% Determine initial axis vectors from theta
v = [ R(3,2,:)-R(2,3,:),...
    R(1,3,:)-R(3,1,:),...
    R(2,1,:)-R(1,2,:)] ./ (repmat(2*sin(theta),[1,3]));

% Handle the degenerate cases where theta is divisible by pi
singularLogical = mod(theta, cast(pi,'like',R)) == 0;
numSingular = sum(singularLogical,3);
assert(numSingular <= length(singularLogical));

if any(singularLogical)
    vspecial = zeros(3,numSingular,'like',R);
    
    inds = find(singularLogical);
    for i = 1:sum(singularLogical)
        [~,~,V] = svd(eye(3)-R(:,:,inds(i)));
        vspecial(:,i) = V(:,end);
    end
    v(1,:,singularLogical) = vspecial;
end

% Extract final values
theta = reshape(theta,[numel(theta) 1]);
v = reshape(v,[3, numel(v)/3]).';

axang = cat(2, v, theta);

axang = [axang(1)*axang(4),axang(2)*axang(4),axang(3)*axang(4)];

end
