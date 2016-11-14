function [R, C] = p3p_RC( N, u, X, K )
%P3P_RC  P3P problem - absolute camera pose and orientation
%   [R C] = p3p_RC( N, u, X )
%     
%   Input:
%     N .. 1x3, distances (eta) along rays, single solution, obtained from
%           p3p_distances. If [N1 N2 N3] = p3p_distances( ... ), then for 
%           particular i the distances are 
%                 N = [ N1(i) N2(i) N3(i) ]
%     u .. 2x3, corresponding three image points (column vectors)
%
%     X .. 3x3, corresponding three 3D points (column vectors)
%
%     K .. 3x3 calibration matrix
%       
%   Output:
%     R .. matrix of rotation (3x3)
%     C .. camera centre
u = [u; [1,1,1]];

invK = inv(K);

nu_g = invK * u;

y1 = N(1) * (nu_g(:, 1)/ norm(nu_g(:, 1)));
y2 = N(2) * (nu_g(:, 2)/ norm(nu_g(:, 2)));
y3 = N(3) * (nu_g(:, 3)/ norm(nu_g(:, 3)));
Y = [y1, y2, y3];

z2e = y2 - y1;
z3e = y3 - y1;
z1e = cross(z2e, z3e);
Ze = [z1e, z2e, z3e];

z2d = X(:, 2) - X(:, 1);
z3d = X(:, 3) - X(:, 1);
z1d = cross(z2d, z3d);
Zd = [z1d, z2d, z3d];

R = Ze/Zd;
C = X - R'*Y; %for certainity
C = C(:, 1);