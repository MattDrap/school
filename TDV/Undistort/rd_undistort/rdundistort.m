function [ u1, v1 ] = rdundistort( u, varargin )
% RDUNDISTORT    Radial distortion wrapper. Mapping from uR to uL.
%
%   UVL = CAMRDUNDISTORT( UR, VR, PARS ) or
%   UVL = CAMRDUNDISTORT( UVR, PARS ) or
%   [ UL, VL ] = CAMRDUNDISTORT( UR, VR, PARS ) or
%   [ UL, VL ] = CAMRDUNDISTORT( UVR, PARS ) transforms raw camera image
%       points (uR) to the linear camera image points (uL). The core radial
%       distortion/undistortion function is part of the RD model in PARS.
%
%   UR, VR - 1xN - or
%   UVR - 2xN - points to be transformed
%   PARS - radial distortion struct from the camera. Mandatory fields:
%           A, S, M matrices,
%           uvn - no-distortion point,
%           forw - function handle to primitive forward rd function%
%   UL, VL - 1xN - or
%   UVL - 2xN - undistorted points (of the same dimensions as input)
%
% See also: CAMRDDISTORT, CAMPTUNDISTORT, CAMIMUNDISTORT

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

iSA = inv(p.S*p.A);
x3 = iSA*tohomo([u(:)';v(:)']); % fromhomo unneccessary
x30 = inv(p.A)*[p.uvn;1];

uv1 = p.M*p.A*tohomo(p.forw(x3(1,:), x3(2,:), x30(1:2), p));

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