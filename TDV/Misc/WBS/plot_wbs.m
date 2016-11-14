function [ax1 ax2] = plot_wbs( im1, im2, u1, u2, plotspec )
%PLOT_WBS  Plot wide baseline correspondences
%
%   [ax1, ax2] = plot_wbs( im1, im2, u1, u2 [, plotspec ] )
%
%   Input:
%     im1, im2 .. the first and the second image or axis handles.
%     u1, u2   .. corresponding points in the first and in the second image,
%                 respectively.  Euclidean coordinates, columns [x;y].
%     plotpsec .. cell, plot specification for markers,
%                 default { 'color', 'w', 'linewidth', 1 }
%
%  Output:
%    ax1, ax2 .. axis handle for the first and the second image, respectively.

% (c) 2010-10-18, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

n = size( u1, 2 );
c = colors( n );

if( nargin < 5 )
  plotspec = { 'color', 'w', 'linewidth', 1 };
end

if( ishandle( im1 ) )
  axes( im1 );
else
  clf
  subplot( 1,2,1)
  image( im1 );
  axis image
end

if( nargout > 0 ), ax1 = gca; end

hold on
for i = 1:n
  line( u1(1,i), u1(2,i), 'markerfacecolor', c(i,:), ...
        'markersize', 7, 'marker', 'o', plotspec{:} );
end

hold off

if( ishandle( im2 ) )
  axes( im2 );
else
  subplot( 1,2,2)
  image( im2 );
  axis image
end

if( nargout > 0 ), ax2 = gca; end

hold on
for i = 1:n
  line( u2(1,i), u2(2,i), 'markerfacecolor', c(i,:), ...
        'markersize', 7, 'marker', 'o', plotspec{:} );
end

hold off


function c = colors( n )

cl = [ 1   0   0;
       0 0.8   0;
       1   1   0;
       0   0   0;
       0   0.5 0.5;
       0   0   1;
       1   0   1;
      .5   0   .5;
       1   .5  0;

     ];

i = rem( 0:(n-1), size( cl, 1 ) ) + 1;

c = cl( i, : );