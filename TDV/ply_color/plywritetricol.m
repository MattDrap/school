function plywritetricol(Tri,Pts,Col,varargin)
%PLYWRITETRI  Write a PLY file from TRI and PTS arrays.
%   PLYWRITETRI(TRI,PTS,COL,FILENAME,...) writes a PLY 3D data file
%   from the mesh data TRI and PTS.  PTS is a Nx3 matrix of mesh
%   vertices and TRI is a Mx3 array of triangular connectiviy.
%   Every row of TRI describes a triangle with three point 
%   indices.
%   COL is RGB color in Nx3 matrix in range 0-255 (uint8).
%
%   Example:
%   % make a pyramid
%   Tri = [2,1,4; 2,4,3; 1,2,5; 1,5,4; 4,5,3; 2,3,5];
%   Pts = [0,0,0; 1,0,0; 1,1,0; 0,1,0; 0.5,0.5,1.6];
%   Col = 255*[0,0,0; 1,0,0; 1,1,0; 0,1,0; 0.5,0.5,1.6];
%   trisurf(Tri,Pts(:,1),Pts(:,2),Pts(:,3)); axis equal;
%   plywritetri(Tri,Pts,Col,'pyramid.ply','ascii');
%
%   See also: PLYWRITE

% Pascal Getreuer 2004

if nargin < 3, error('Not enough input arguments.'); end
if size(Tri,2) ~= 3, error('TRI must have 3 columns.'); end
if size(Pts,2) ~= 3, error('PTS must have 3 columns.'); end
if size(Col,2) ~= 3, error('COL must have 3 columns.'); end
if any(Col(:)>255), error('COL must be 0-255'); end

Data.vertex.x = Pts(:,1);
Data.vertex.y = Pts(:,2);
Data.vertex.z = Pts(:,3);

Col = uint8(Col);

Data.vertex.diffuse_red = Col(:,1);
Data.vertex.diffuse_green = Col(:,2);
Data.vertex.diffuse_blue = Col(:,3);

Data.face.vertex_indices = cell(size(Tri,1),1);

for k = 1:size(Tri,1)
   Data.face.vertex_indices{k} = uint32(Tri(k,:) - 1);
end

plywrite(Data,varargin{:});

