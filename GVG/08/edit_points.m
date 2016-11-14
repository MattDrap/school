function [u edges] = edit_points( im, u, edges, varargin )
%EDIT_POINTS  Image point/correspondence edit tool.
%
%  [u edges] = edit_points( im, u, edges, [ key-value options ... ] )
%
%  This tool creates a new figure, and waits for pressing the enter in the
%  command window.
%
%  Input:
%     im        .. images, cell array
%     u         .. points, cell array; 
%                  u{i} is 2xn matrix of n points in the  image im{i}.
%                  Can be empty.
%     edges     .. 2xm matrix of m edges, each column is one edge [i1;i2],
%                  connecting the points u{i}(i1) and u{i}(i2) for all i
%                  (i.e. in all images).
%                  Can be empty.
%
%     key-value options .. pairs of key (string) and value, e.g.
%             edit_points( ..., 'edge_style', { 'r', 'linewidth', 2 } )
%             can be used to set the line style of edges. 
%             See the source code for the options and values (the fields of
%             the opt structure).
%
%  Mouse control:
%     left-click    .. add a new point to the current axes or edit the location
%                      of a selected point
%     right-click   .. set the selected point as a starting point of an edge
%     middle-click  .. create a new edge from the starting point to the
%                      selected point
%
%  Keyboard control:
%     .         .. show all points as dots without labels
%     x         .. show all points as crosses with labels
%     backspace .. remove the last point from  the current axes
%     z         .. zoom-in to corresponding points, iterate all points
%     Z         .. zoom out to full image
%
%  Example:
%
%    u1 = []; u2 = []; 
%    u = edit_points( { im1, im2 }, { u1, u2 } );
%    u1 = u{1}; u2 = u{2};

% (c) 2012-04-13, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

%% Arguments parsing
if( ~iscell( im ) ), im = { im }; end
if( isempty( u ) ), u = cell( size( im ) ); end
if( ~iscell( u ) ), u = { u }; end

if( isempty( edges ) ), edges = zeros( 2, 0 ); end
if( size( edges, 1 ) ~= 2 ), error( 'Edges must be 2xn matrix' ); end

edges = unique( sort( edges )', 'rows' )'; % edges are unique, [i1; i2], i1<i2

opt.dot_style = { 'marker', '.', 'color', 'b' };
opt.x_style = { 'marker', 'x', 'color', 'r', 'markersize', 10 };
opt.text_style = { 'backgroundcolor', [1 0.6 0.6], ...
                   'fontsize', 12 };
opt.edge_style = { 'y' };
opt.zoom_range = 50;

for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i+1}; end

%% Create figure
fig = figure;
colormap gray
ax = {};

switch( numel( im ) )
  case 1
    ax{1} = gca;
    imagesc( im{1} );
    axis equal;
    hold on
  case 2
    ax{1} = axes( 'pos', [0.02 0.02 0.46 0.96] );
    imagesc( im{1} )
    axis equal
    hold on
    
    ax{2} = axes( 'pos', [0.52 0.02 0.46 0.96] );
    imagesc( im{2} )
    axis equal
    hold on
 
  otherwise
    error( 'Not implemented' );
end

for j = 1:numel( im )
  set( ax{j}, 'userdata', size( u{j}, 2 ) );
  set( findobj( ax{j}, 'type', 'image' ), 'buttondownfcn', @add_pt );
end

set( fig, 'keypressfcn', @handle_key );

%% Create points and edges
for j = 1:numel( im )
  set( fig, 'currentaxes', ax{j} );
  
  for i = 1:size( u{j}, 2 )
    one_pt( u{j}(:,i), i );
  end

  for i = 1:size( edges, 2 )
    if( all( size( u{j}, 2 ) >= edges( :, i ) ) )
      one_edge( u{j}( :, edges( :, i ) ), edges( :, i ) );
    end
  end
end

%% Wait for finish and retrieve data
input( 'Adjust the points and press enter...\n' );

% extract point coordinates
u = {};
maxl = 0;
for j = 1:numel( im )
  h = findobj( ax{j}, 'tag', 'POINT' );
  maxl = max( maxl, numel( h ) );
  
  x = get( h, 'xdata' );
  y = get( h, 'ydata' );
  i = get( h, 'userdata' );
  if( numel( h ) > 1 )
    i = [i{:}];
    u{j} = [ x{i}; y{i} ];  
  else
    u{j} = [ x; y ];
  end
end

% edges are allready up-to date, remove these having no points (points deleted)
edges = edges( :, edges( 1,:) <= maxl & edges( 2,:) <= maxl );

close( fig );

%% one_pt
  function [h h2] = one_pt( up, lbl )
  h = plot( up(1), up(2), opt.x_style{:}, 'ButtonDownFcn', @edit_pt, ...
            'tag', 'POINT', 'userdata', lbl );
  set( h, 'zdata', 1 );
  h2 = text( up(1), up(2), sprintf( '%i', lbl ), ...
             'verticalalign', 'bottom', 'horizontalalign', 'center', ...
             opt.text_style{:}, 'tag', 'LABEL', 'userdata', lbl );
  end

%% one_edge
  function one_edge( ue, ie )
  if( ie(1) > ie(2) ), ie = ie( [2 1] ); end
  h = plot( ue( 1, : ), ue( 2, : ), opt.edge_style{:}, 'userdata', ie(:), ...
            'tag', 'EDGE', 'ButtonDownFcn', @edit_edge );
  set( h, 'zdata', [0 0] );
  end

%% add_pt (callback)
  function add_pt( a, ~ )
  switch( get( gcf, 'selectiontype') )
    case 'normal'
      ha = get(a,'parent' );
      pt = get(ha, 'currentpoint' );
      lbl = get(ha, 'userdata' ) + 1;
      ux = pt([1 3] )';
      one_pt( ux, lbl );
      set( ha, 'userdata', lbl );
      fprintf( 'Adding point %i\n', lbl );

      for lbl2 = edges( 2, edges(1,:) == lbl )
        hu = findobj( ha, 'tag', 'POINT', 'userdata', lbl2 );
        if( ~isempty( hu ) )
          u2 = [ get( hu, 'xdata' ); get( hu, 'ydata' ); ];
          one_edge( [ ux u2 ], [lbl lbl2 ] );
        end
      end

      for lbl1 = edges( 1, edges(2,:) == lbl )
        hu = findobj( ha, 'tag', 'POINT', 'userdata', lbl1 );
        if( ~isempty( hu ) )
          u1 = [ get( hu, 'xdata' ); get( hu, 'ydata' ); ];
          one_edge( [ u1 ux ], [lbl1 lbl] );
        end
      end
  end
  end
     
%% handle_key (callback)
  function handle_key(~, key)
  if( isequal( key.Character, upper( key.Key ) ) ), key.Key = key.Character; end

  switch( key.Key )
    case 'period' % show all points using dot_style, hide labels
      set( findall( gcf, 'tag', 'POINT' ), opt.dot_style{:} );
      set( findall( gcf, 'tag', 'LABEL' ), 'visible', 'off' );
    
    case 'x' % show all points using x_style, show labels
      set( findall( gcf, 'tag', 'POINT' ), opt.x_style{:} );
      set( findall( gcf, 'tag', 'LABEL' ), 'visible', 'on' );
    
    case 'backspace' % remove last point from the current axes
      lbl = get( gca, 'userdata' );

      if( lbl > 0 )
        delete( findall( gca, 'tag', 'POINT', 'userdata', lbl ) );
        delete( findall( gca, 'tag', 'LABEL', 'userdata', lbl ) );
        fprintf( 'Removed point %i\n', lbl );

        % delete edge lines from the current axes
        for edge = edges( :, edges(1,:) == lbl | edges(2,:) == lbl )
          delete( findobj( gca, 'tag', 'EDGE', 'userdata', edge ) );
        end

        set( gca, 'userdata', lbl - 1 );
      end
    
    case 'z' 
      % zoom in all axes to corresponding points
      lastz = getappdata( gcf, 'lastz' );
      if( isempty( lastz ) ), lastz = 0; end
      
      lastz = lastz + 1;
      is = 0;
      for k = 1:numel( im )
        hu = findobj( ax{k}, 'tag', 'POINT', 'userdata', lastz );
        if( isempty( hu ) )
          set( ax{k}, 'xlim', [1 size(im{k},2)], 'ylim', [ 1 size(im{k},1) ] );
          axis( ax{k}, 'equal' );
        else
          is = 1;
          x = get( hu, 'xdata' );
          y = get( hu, 'ydata' );
          set( ax{k}, 'xlim', x(1) + [ -opt.zoom_range opt.zoom_range ], ...
                      'ylim', y(1) + [ -opt.zoom_range opt.zoom_range ] );
        end
      end
      if( ~is ), lastz = 0; end
      setappdata( gcf, 'lastz', lastz );

    case 'Z'
      for k = 1:numel( im )
        set( ax{k}, 'xlim', [ 1 size(im{k},2) ], 'ylim', [ 1 size(im{k},1) ] );
        axis( ax{k}, 'equal' );
      end
  end
  end

%% edit_edge (callback)
  function edit_edge( a, ~ )
  switch( get( gcf, 'selectiontype') )
    case 'normal'
      edge = get( a, 'userdata' );
      fprintf( 'Deleting edge %i-%i\n', edge );

      delete( findall( gcf, 'tag', 'EDGE', 'userdata', edge ) );
      edges = edges( :, edges(1,:) ~= edge(1) & edges(2,:) ~= edge(2) );
  end
  end
  
%% edit_pt (callback)
  function edit_pt( hu, ~ )
  ha = get( hu, 'parent' );

  switch( get( gcf, 'selectiontype') )
    case 'normal'
      % edit point location
      lbl = get( hu, 'userdata' );
      
      hl = findobj( ha, 'tag', 'LABEL', 'userdata', lbl );
      set( [hu hl], 'visible', 'off' );
      
      [x, y] = ginput(1);
      
      set( hu, 'xdata', x, 'ydata', y, 'visible', 'on'  );
      set( hl, 'pos', [x y 0], 'visible', 'on' );

      % update edges
      he = findall( ha, 'tag', 'EDGE' );
      e = get( he, 'userdata' );
      if( iscell(e) ), e = [ e{:} ]; end
      
      if( ~isempty( e ) )
        for inx = find( e(1,:) == lbl )
          xe = get( he(inx), 'xdata' );
          ye = get( he(inx), 'ydata' );
          set( he(inx), 'xdata', [x xe(2)], 'ydata', [y ye(2)] );
        end
        
        for inx = find( e(2,:) == lbl )
          xe = get( he(inx), 'xdata' );
          ye = get( he(inx), 'ydata' );
          set( he(inx), 'xdata', [xe(1) x], 'ydata', [ye(1) y] );
        end
      end

    case 'alt'
      % set the first point for a new edge
      i1 = get( hu, 'userdata');
      setappdata( ha, 'first', i1 );
      fprintf( 'Edge point 1 = %i\n', i1 );
    case 'extend'
      % create an edge (if the first point is set )
      i1 = getappdata( ha, 'first' );
      if( ~isempty( i1 ) )
        i2 = get( hu, 'userdata' );
        if( i1 > i2 ), [ i2 i1 ] = deal( i1, i2 ); end
        
        if( ~any( ( edges( 1, : ) == i1 ) & ( edges( 2, : ) == i2 ) ) )
          fprintf( 'Creating edge %i-%i\n', i1, i2 );
          edges = [ edges [i1; i2] ];
          
          ca = gca;
          for k = 1:numel(im)
            h1 = findobj( ax{k}, 'tag', 'POINT', 'userdata', i1 );
            h2 = findobj( ax{k}, 'tag', 'POINT', 'userdata', i2 );
            
            if( ~isempty( h1 ) && ~isempty( h2 ) )
              u1 = [ get( h1, 'xdata' ); get( h1, 'ydata' ) ];
              u2 = [ get( h2, 'xdata' ); get( h2, 'ydata' ) ];
              set( fig, 'currentaxes', ax{k} );
              one_edge( [ u1 u2 ], [ i1; i2 ] );
            end
          end
          set( fig, 'currentaxes', ca );
        else
          fprintf( 'Edge %i-%i allready exists\n', i1, i2 );
        end
      end
  end
  end
end
