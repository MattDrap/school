%DEMO_WBS  Demo of WBS pairwise matcher.

% (c) 2010-10-17, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( ~exist( 'wbs_default_cfg', 'file' ) )
  error( 'Cannot find WBS matcher. Probably PATH is not set.' );
end

% read images
fprintf( 'Reading images ...\n' )
im1=imread('1.jpg');
im2=imread('2.jpg');
im3=imread('3.jpg');


% compute image descriptors
fprintf( 'Computing descriptors ...\n' )
cfg  = wbs_default_cfg;
pts1 = wbs_describe_image(im1, cfg);
pts2 = wbs_describe_image(im2, cfg);
pts3 = wbs_describe_image(im3, cfg);


fprintf( 'Matching ...\n' )
% match all pairs using precomputed descriptions
[ pc12 m12 ] = wbs_match_descriptions( pts1, pts2, cfg );
[ pc23 m23 ] = wbs_match_descriptions( pts2, pts3, cfg );
[ pc31 m31 ] = wbs_match_descriptions( pts3, pts1, cfg );

figure(1)
plot_wbs( im1, im2, pc12(1:2,:), pc12(3:4,:) )
figure(2)
plot_wbs( im2, im3, pc23(1:2,:), pc23(3:4,:) )
figure(3)
plot_wbs( im3, im1, pc31(1:2,:), pc31(3:4,:) )
