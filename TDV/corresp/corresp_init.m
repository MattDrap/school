function corresp = corresp_init( n )
%CORRESP_INIT  Initialise data structure with correspondence tables.
%
%  corresp = corresp_init( n )
%
%  Input:
%    n  .. number of cameras (The cameras will be identified as 1..n)
%
%  Output:
%    corresp .. data structure with empty correspondence tables

% (c) 2010-11-18, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

corresp = struct;
corresp.n = n;
% image-to-image correspondences
corresp.m  = cell( n, n );  
% Correspondences between camera i1 and i2, where i1 ~= i2, are stored in
% corresp.m{ min(i1,i2), max(i1,i2) }. I.e., cell matrix corresp.m has
% diagonal and under-diagonal entries empty.
                            
corresp.mcount = zeros( n, n );
% numbers of correspondences


% scene-to-image correspondences (pairs [X_id u_id])
corresp.Xu = cell( n, 1 );
corresp.Xucount = zeros( n, 1 );
corresp.Xu_verified = cell( n, 1 ); % flags, tentative or verified

for i=1:n
  corresp.Xu{i} = zeros( 0, 2 );
end

% flag for each camera, true if the camera is selected, false otherwise
corresp.camsel = false( 1, n );

% flag: working phase
corresp.state = 'init';
