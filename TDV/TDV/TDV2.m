%close all;
addpath('../Misc');
addpath('../Misc/WBS');
addpath('../Misc/WBS/wbs');

if( ~exist( 'wbs_default_cfg', 'file' ) )
  error( 'Cannot find WBS matcher. Probably PATH is not set.' );
end

list = dir('../IMG_D');
cfg  = wbs_default_cfg;
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));
%%
%Computing image descriptors
for i = 1:length(image_names)
    if ~exist([image_names{i}(1:end - 3) 'mat'], 'file')
        fprintf('Reading %d-th image %n', i);
        im = imread(['../IMG_D/' image_names{i}]);
        fprintf('Computing descriptors for %d-th image%n', i);
        pts = wbs_describe_image(im, cfg);
        save([image_names{i}(1:end - 3) 'mat'], 'pts');
    end
end
%%
matchmatrix = cell(length(image_names));
matchmatrix2 = cell(length(image_names));
for i = 1:length(image_names)
    pts1 = load([image_names{i}(1:end - 3) 'mat']);
    i
    for j = i+1:length(image_names)
        pts2 = load([image_names{j}(1:end - 3) 'mat']);
        j
        [ pc, m ] = wbs_match_descriptions(pts1.pts , pts2.pts, cfg );
        matchmatrix{i, j} = pc;
        matchmatrix2{i, j} = m;
        save('Corr.mat', 'matchmatrix', 'matchmatrix2');
    end
end
%%
im1 = imread(['../IMG_D/' image_names{2}]);
im2 = imread(['../IMG_D/' image_names{3}]);

pc = matchmatrix{2, 3};
pts1 = load([image_names{2}(1:end - 3) 'mat']);
pts2 = load([image_names{3}(1:end - 3) 'mat']);



plot_wbs(im1, im2, pc(1:2, :), pc(3:4, :));

%%
%consistent
im1 = imread(['../IMG_D/' image_names{2}]);
im2 = imread(['../IMG_D/' image_names{3}]);
im3 = imread(['../IMG_D/' image_names{4}]);

pc23 = matchmatrix{2, 3};
pc34 = matchmatrix{3, 4};
pc24 = matchmatrix{2, 4};

m23 = matchmatrix2{2, 3};
m34 = matchmatrix2{3, 4};
m24 = matchmatrix2{2, 4};

% pts1 = load([image_names{2}(1:end - 3) 'mat']);
% pts2 = load([image_names{3}(1:end - 3) 'mat']);
% pts3 = load([image_names{4}(1:end - 3) 'mat']);

%%
[p2_, p3_, p4_] = ThreeWConsistency(m23, m24, m34, pc23, pc24, pc34);


c = colors( size(p2_, 2) );
[H, W, C] = size(im1);
figure;
subplot(1, 3, 1);
hold on;
im1 = imrotate(im1, 270);
image(im1);
scatter(H - p2_(2, :), p2_(1, :),7, c, 'marker', 'o');
hold off;
subplot(1, 3, 2);
hold on;
im2 = imrotate(im2, 270);
image(im2);
scatter(H - p3_(2, :), p3_(1, :), 7, c, 'marker', 'o');
hold off;
subplot(1, 3, 3);
hold on;
im3 = imrotate(im3, 270);
image(im3);
scatter(H - p4_(2, :), p4_(1, :), 7, c, 'marker', 'o');