
close all; clear; clc;

%% Read and show images.
[im, info] = read_images(fullfile('images', 'color*'));
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
w = get_weights(L, Z);

%% Estimate exposure.
assert(numel(Z) < 1e6);
[E, t] = estimate_exposure(Z, w);
% Create a (possibly incomplete) HDR image.
hdr = nan(size(im{1}));
hdr(idx) = E;
% ...or just reshape if all pixels were used.
% hdr = reshape(E, size(im{1}));

%% Plot estimated exposure times.
figure('Name', 'Exposure times'); plot(t, '-'); xlabel('j'); ylabel('t_j');

%% Compose full HDR (week 2).
 w = get_weights(L, 0:L-1);
 hdr = compose_hdr(im, t, w, 0:L-1);

%% Reconstruct one of the images and compare it to the original.
i = randi(numel(im));
rendered = reconstruct_image(hdr, t(i), 0:L-1);
set(show_images({rendered, im2double(im{i})}), 'Name', 'Reconstructed image with original');

%% Apply tone mapping.
figure('Name', 'HDR gamma');     imshow(tonemap_gamma(hdr, 1/6));
% (week 2)
figure('Name', 'HDR log');       imshow(tonemap_log(hdr));
figure('Name', 'HDR equalized'); imshow(tonemap_histeq(hdr));
