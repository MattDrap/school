
close all; clear; clc;

%% Read and show images.
[im, info] = read_images(fullfile('images', 'lamp*'));
set(show_images(im), 'Name', 'Input images');
% Subsample if necessary (week 1).
im = cellfun(@(im) imresize(im, 128/length(im)), im, 'UniformOutput', false);
L = double(intmax(class(im{1}))) + 1;

%% Prepare inputs.
% Sample pixels if the images are too large...
N = min(numel(im{1}), 50000);
idx = randsample(numel(im{1}), N);  % (a column vector)
Z = cell2mat(cellfun(@(im) double(im(idx)), im, 'UniformOutput', false));
% ...or take all pixels if possible.
% Z = cell2mat(cellfun(@(im) double(im(:)), im, 'UniformOutput', false));
t = arrayfun(@(info) info.DigitalCamera.ExposureTime, info);
w = get_weights(L, Z);
lambda = 2;

%% Estimate irradiance and inverse response function.
assert(numel(Z) < 1e6);
[E, finv] = estimate_response(Z, t, w, lambda);
% Create a (possibly incomplete) HDR image.
hdr = nan(size(im{1}));
hdr(idx) = E;
% ...or just reshape if all pixels were used.
% hdr = reshape(E, size(im{1}));

%% Plot inverse response function.
figure('Name', 'Inverse response function'); plot(0:L-1, finv, '-'); xlabel('Z'); ylabel('X');

%% Compose full HDR (week 2).
% w = get_weights(L, 0:L-1);
% hdr = compose_hdr(im, t, w, finv);

%% Reconstruct one of the images and compare it to the original.
i = randi(numel(im));
rendered = reconstruct_image(hdr, info(i).DigitalCamera.ExposureTime, finv);
set(show_images({rendered, im2double(im{i})}), 'Name', 'Reconstructed image with original');

%% Apply tone mapping.
figure('Name', 'HDR gamma');     imshow(tonemap_gamma(hdr, 1/6));
% (week 2)
% figure('Name', 'HDR log');       imshow(tonemap_log(hdr));
% figure('Name', 'HDR equalized'); imshow(tonemap_histeq(hdr));
