close all;
clear;

% load the input image and convert it to [0,1] range
img = im2double(imread('images/vessel.jpg'));
[h, w] = size(img);

% show the input image
figure;
image(repmat(img, [1 1 3]));
axis image;
title('Input image');

% compute vertex costs for individual pixels
vertex_cost = 1 - img;

% show computed vertex costs
figure;
imagesc(vertex_cost);
axis image;
colorbar;
title('Vertex costs for individual pixels');

% find optimum solution using dynamic programming
[path, path_cost] = dp_path(vertex_cost);

% show computed path costs
figure;
imagesc(path_cost);
axis image;
colorbar;
title('Path costs for individual pixels');

% build image with marked vessel by setting color of path pixels to red
img_path = repmat(img, [1 1 3]);
for i = 1:h
    img_path(i,path(i),:) = [1, 0, 0];
end

% show image with trace
figure;
image(img_path);
axis image;
title('Image with traced vessel');
