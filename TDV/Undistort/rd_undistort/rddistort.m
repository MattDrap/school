function [ u1, v1 ] = rddistort( u, varargin )
%RDDISTORT  Radial distortion wrapper. Mapping from uL to uR.
%
%   UVR = CAMRDDISTORT( UL, VL, PARS ) or
%   UVR = CAMRDDISTORT( UVL, PARS ) or
%   [ UR, VR ] = CAMRDDISTORT( UL, VL, PARS ) or
%   [ UR, VR ] = CAMRDDISTORT( UVL, PARS ) transforms linear camera image
%       points (uL) to the raw camera image points (uR). The core radial
%       distortion/undistortion function is part of the RD model in PARS.
%
%   UL, VL - 1xN - or
%   UVL - 2xN - points to be transformed
%   PARS - radial distortion struct from the camera. Mandatory fields:
%           A, S, M matrices,
%           uvn - no-distortion point,
%           forw - function handle to primitive forward rd function
%   UR, VR - 1xN - or
%   UVR - 2xN - distorted points (of the same dimensions as input)
%
% See also: CAMRDUNDISTORT, CAMPTUNDISTORT, CAMIMUNDISTORT
 
% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 24 Aug 07
% Last modified: Ondrej Sychrovsky 2009-01-19

if nargin < 3
    if size(u,1) ~= 2
        error 'Argument u must be a 2 x n matrix of points, one per column';
    end
    v = u(2,:);
    u = u(1,:);
    p = varargin{1};
else
    v = varargin{1};
    p = varargin{2};
end

iM = inv(p.M);
iA = inv(p.A);
x1 = iA*iM*tohomo([u(:)'; v(:)']);
x10 = iA*[p.uvn;1];

uv1 = p.S*p.A*tohomo(p.back(x1(1,:), x1(2,:), x10(1:2), p));

if( nargout == 2 ),
    u1 = reshape(uv1(1,:), size(u));
    v1 = reshape(uv1(2,:), size(u));
else
    u1 = uv1(1:2,:);
end


function y = tohomo(x)
%
% y = tohomo(x)
%
%   Converts ordinary to homogeneneous coordinates by adding a unit
%   coordinate. Works per columns.
 
% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 25 Apr 06
 
 if ndims(x) > 2
  error 'Does not work for 3 and more dimensions'
 end

 if size(x,1)==1
  y = [x,1];
 else
  y = [x;ones(1,size(x,2))];
 end