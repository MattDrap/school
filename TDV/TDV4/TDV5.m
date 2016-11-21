%INIT
K = [  4.30662478e+03,   0.00000000e+00,   2.59136950e+03 / 2;
      0,   4.32151461e+03,   1.42629560e+03 / 2 ;
      0,   0,   1];
  
addpath('../p5');
addpath('../TDV2');
addpath('../Misc');
addpath('../TDV3');
addpath('../toolbox');
addpath('../ba');
addpath('../corresp')
addpath('../p3p');
addpath('../@ge_vrml');
addpath('../rectify');
addpath('../gcs');
addpath('../psr');
addpath('../ply_color');

if( ~exist( 'p5gb', 'file' ) )
  error( 'Cannot find five-point estimator. Probably PATH is not set.' );
end

list = dir('../DataUnDistorted');
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));
%%

Xcloud = [];
for i = 1:length(image_names) - 1
    img1 = imread(['../DataUnDistorted/' image_names{i}]);
    img1 = imresize(img1, 0.5);
    for j = i+1:length(image_names)
        F = vgg_F_from_P(K*cameraSet{i}, K*cameraSet{j});
        
        img2 = imread(['../DataUnDistorted/' image_names{j}]);
        img2 = imresize(img2, 0.5);
        
        [Ha, Hb, img1_r, img2_r] = rectify( F, img1, img2 ); 
        D = gcs( img1_r, img2_r, [] );
        Par = Ha * P1;
        Pbr = Hb * P2;
        
        [W, H, C] = size(img1_r);
        
        not_nan = ~isnan(D);
        
        [mY, mX] = ind2sub([W,H], find(not_nan));
        
        u = [mX(:), mY(:)]';
        u2 = [mX-D(not_nan), mY]';
        
        X = Pu2X(Par, Pbr, e2p(u), e2p(u2));
        Xcloud = [Xcloud, X];
    end
end