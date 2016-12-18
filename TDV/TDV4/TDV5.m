%INIT
% K = [  4.30662478e+03,   0.00000000e+00,   2.59136950e+03 / 2;
%       0,   4.32151461e+03,   1.42629560e+03 / 2 ;
%       0,   0,   1];

 K=[[  2.15102295e+03  0   1.29395810e+03],
[  0   2.15892669e+03   7.13809453e+02],
[  0   0  1.00000000e+00]];

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
%%

if( ~exist( 'p5gb', 'file' ) )
  error( 'Cannot find five-point estimator. Probably PATH is not set.' );
end

load('TDV4.mat');

list = dir('../IMG_D');
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));
%%
pairs = [1 1 4 4 7 7 10 10,  1 2 3 4 5 6  7  8  9;
         2 3 5 6 8 9 11 12,  4 5 6 7 8 9 10 11 12];
pairs = [4; 5];
Xclouds = cell(size(pairs, 2), 1);
poisson = cell(size(pairs, 2), 1);
for i = 1:size(pairs, 2)
    fprintf('Disparity map for pair %d \n', i);
    img1 = imread(['../IMG_D/' image_names{pairs(1, i)}]);
    
    P1 = K*cameraSet{pairs(1, i)};
    P2 = K*cameraSet{pairs(2, i)};
    F = vgg_F_from_P(P1, P2);

    img2 = imread(['../IMG_D/' image_names{pairs(2, i)}]);
    
    D_name = sprintf('D%d%d.mat', pairs(1, i), pairs(2, i));
    if(exist(D_name, 'file'))
        load(D_name);
    else
        [Ha, Hb, img1_r, img2_r] = rectify( F, img1, img2 );
        D = gcs( img1_r, img2_r, [] );
        
        not_nan = isnan(D);
        se = strel('rectangle', [4, 3]);
        dilated = imdilate(not_nan, se);
        D(dilated) = NaN;
    end
    %
    Par = Ha * P1;
    Pbr = Hb * P2;
    
    [H, W, C] = size(img1_r);

    not_nan = ~isnan(D);

    [mY, mX] = ind2sub([H,W], find(not_nan));

    u = [mX(:), mY(:)]';
    u2 = [mX-D(not_nan), mY]';
    
    save(sprintf('D%d%d', pairs(1, i), pairs(2, i)), 'D');
    %%
    fprintf('Triangulation of points - %d points\n', size(u, 2));
    X = Pu2X(Par, Pbr, e2p(u), e2p(u2));
    X = p2e(X);
    
    %Remove points outside possible scope
    zstd = 7;
    log = X(3, :) > 21 + zstd | X(3, :) < 21 - zstd;
    X = X(:, ~log);
    %Assign new points
    Xclouds{i} = X;
    
    %Poisson
    fprintf('Preparing Poisson\n');
    iX=nan(H,W,3);
    
    inds = find(not_nan);
    inds(log) = [];
    inds2 = inds + H*W;             %trick with dimensions
    inds3 = inds + 2*H*W;           %linear indexing 3d by accumulating
    inds = [inds; inds2; inds3];    %same index with an offset to achieve assignment
                                    % of iX(mX, mY, :) = X;
    tX = X';
    tX = tX(:);
    
    iX(inds) = tX;
    poisson{i} = iX;
end
%%
fprintf('Calculating poisson surf. reconstruction');
psr(poisson);
%%
expX = [];
for i = 1:size(pairs, 2)
    expX = [expX, Xclouds{i}];
end
Rt = cameraSet;

ge = ge_vrml( 'out_d.wrl' );
ge = ge_cams( ge, Rt, 'plot', 1 );  % P is a cell matrix containing cameras without K,
                                    % { ..., [R t], ... }
ge = ge_points( ge, expX );       % Xcloud contains euclidean points (3xn matrix)
ge = ge_close( ge );
