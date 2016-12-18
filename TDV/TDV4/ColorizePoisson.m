 K=[[  2.15102295e+03  0   1.29395810e+03],
[  0   2.15892669e+03   7.13809453e+02],
[  0   0  1.00000000e+00]];

load('TDV4.mat');

[tri, pts] = plyread('psr.ply','tri');

col = zeros(size(pts));

list = dir('../IMG_D');
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));

pts = pts';
for i=1:12
    img = imread(['../IMG_D/' image_names{i}]);
    [H,W,C] = size(img);
    P = K*cameraSet{i};
    proj = P * e2p(pts);
    proj = p2e(proj);
    
    proj = round(proj);
    logs = proj(1, :) > 1 & proj(1, :) < W & proj(2, :) > 1 & proj(2, :) < H;
    proj = proj(:, logs);
    inds = find(logs);
    for k = 1:length(inds)
        col(inds(k), :) = col(inds(k), :) + squeeze(double(img(proj(2, k), proj(1, k), :)))';
    end
end
col = col./12;
col = round(col);
% save the result with color
plywritetricol(tri,pts',col,'psr_col.ply');