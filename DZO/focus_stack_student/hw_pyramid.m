function hw_pyramid()

close all;
clear;

im = imread('images/jaybird.jpg');
im = rgb2gray(im2double(im));
[h, w] = size(im);

down_im = im_down(im);
up_im = im_up(down_im, [h w]);

figure();
plot_im(2, 2, 1, im, 'Original');
plot_im(2, 2, 2, down_im, 'Downsized');
plot_im(2, 2, 3, up_im, 'Upsized');

[lower_layer, residuals] = pyr_down(im);
upper_layer = pyr_up(lower_layer, residuals);

figure();
plot_im(2, 2, 1, im, 'Original');
plot_im(2, 2, 2, lower_layer, 'Lower layer');
plot_res(2, 2, 3, residuals, 'Residuals');
plot_im(2, 2, 4, upper_layer, 'Reconstructed');

fprintf('Fig 2: max. abs. difference of original and reconstructed: %d\n', ...
    max(abs(im(:) - upper_layer(:))));

pyr = pyr_build(im, 32);
num_layers = numel(pyr.residuals);

figure();
m = ceil(sqrt(num_layers + 1));
n = ceil(num_layers / m);
for i = 1:num_layers
    plot_res(m, n, i, pyr.residuals{i}, sprintf('Residuals %i', i));
end
plot_im(m, n, num_layers + 1, pyr.bottom_layer, 'Bottom layer');

pyr_im = pyr_reconstruct(pyr);

figure();
plot_im(1, 1, 1, pyr_im, 'Reconstructed from pyramid');

fprintf('Figs 3, 4: max. abs. difference of original image and image reconstructed from pyramid: %d\n', ...
    max(abs(im(:) - pyr_im(:))));

end


function plot_im(m, n, p, im, name)

subplot(m, n, p);
image(repmat(im, [1 1 3]));
axis image;
title(name);

end


function plot_res(m, n, p, residuals, name)

subplot(m, n, p);
colormap('gray');
% show sqrt of residuals instead of plain residuals
% for better visualization
imagesc(sqrt(abs(residuals)).*sign(residuals));
axis image;
title(name);

end
