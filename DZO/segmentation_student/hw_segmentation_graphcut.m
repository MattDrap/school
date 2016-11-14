close all;
clear;

% parameters
NUM_COMPS = 3;
KMEANS_ITER = 100;
NEIGH_TYPE = 8;
LAMBDA_1 = 5;
LAMBDA_2 = 45;

% load RGB image and its labeling
img = im2double(imread('images/llama.jpg'));
lab_in = load_pixel_labeling('images/llama_brush.png');

figure();
imshow(compose_labeled_image(img, lab_in));
title('Image and its initial labeling');

% convert image to list of RGB triples
[h, w, c] = size(img);
rgb = reshape(img, [h * w, c])';

% extract RGB triples labeled as foreground and background
rgb_f = rgb(:,lab_in==1);
rgb_b = rgb(:,lab_in==2);

% estimate GMM for foreground and background pixels
comps_f = kmeans(rgb_f', NUM_COMPS, 'MaxIter', KMEANS_ITER);
[priors_f, means_f, covs_f] = gmm_estimation(rgb_f, comps_f);
comps_b = kmeans(rgb_b', NUM_COMPS, 'MaxIter', KMEANS_ITER);
[priors_b, means_b, covs_b] = gmm_estimation(rgb_b, comps_b);

figure();
hold on;
plot_rgb([rgb_f rgb_b]);
plot_gmm(means_f, covs_f, 'r', 3);
plot_gmm(means_b, covs_b, 'b', 3);
title('Sample RGB values and estimated GMMs');

% compute unary cost [q1(t); q2(t)]
cost_q = cost_unary(rgb, lab_in, priors_f, means_f, covs_f, priors_b, means_b, covs_b);

figure();
subplot(2, 1, 1);
imagesc(reshape(cost_q(1,:), [h w]));
axis image off;
colorbar;
title('Foreground costs');
subplot(2, 1, 2);
imagesc(reshape(cost_q(2,:), [h w]));
axis image off;
colorbar;
title('Background costs');

% build pairs of neighboring pixels for the input image
[pairs, pair_dists] = build_neighborhood(h, w, NEIGH_TYPE);

fprintf('Expected %i neighbors, found %i neighbors.\n', ...
	4 * h * w - 3 * h - 3 * w + 2, size(pairs, 2));

% compute pairwise cost r(t,s)
cost_r = cost_pair(rgb, pairs, pair_dists, LAMBDA_1, LAMBDA_2);

% choose pixel t, find all its neighbors and print their pairwise costs
t = 1587;
neigh_t = sort([pairs(2,(pairs(1,:)==t)), pairs(1,(pairs(2,:)==t))]);
[ti, tj] = ind2sub([h w], t);
fprintf('Pairwise potentials for the pixel (%i,%i):\n', ti, tj);
for k = 1:size(neigh_t, 2)
	tk = neigh_t(k);
	[tki, tkj] = ind2sub([h w], tk);
	fprintf('\t(%i,%i): %f\n', tki, tkj, cost_r(tk));
end

% run graphcut segmentation
lab_seg = segmentation_graphcut(img, lab_in, NUM_COMPS, KMEANS_ITER, NEIGH_TYPE, LAMBDA_1, LAMBDA_2);

figure();
imshow(compose_labeled_image(img, lab_seg));
title('Image and the final segmentation');
