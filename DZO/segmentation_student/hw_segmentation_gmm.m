close all;
clear;

% parameters
NUM_COMPS = 2;
KMEANS_ITER = 100;

% load RGB image and its labeling
img = im2double(imread('images/llama.jpg'));
lab_in = load_pixel_labeling('images/llama_brush.png');

figure();
imshow(compose_labeled_image(img, lab_in));
title('Image and its initial labeling');

% convert image to 2D matrix (list of RGB triples)
[h, w, c] = size(img);
rgb = reshape(img, [h * w, c])';

% extract RGB triples labeled as foreground and background
rgb_f = rgb(:,lab_in==1);
rgb_b = rgb(:,lab_in==2);

% estimate GMM for foreground pixels
comps_f = kmeans(rgb_f', NUM_COMPS, 'MaxIter', KMEANS_ITER);
[priors_f, means_f, covs_f] = gmm_estimation(rgb_f, comps_f);

% estimate GMM for background pixels
comps_b = kmeans(rgb_b', NUM_COMPS, 'MaxIter', KMEANS_ITER);
[priors_b, means_b, covs_b] = gmm_estimation(rgb_b, comps_b);

figure();
hold on;
plot_rgb([rgb_f rgb_b]);
plot_gmm(means_f, covs_f, 'r', 3);
plot_gmm(means_b, covs_b, 'b', 3);
title('Sample RGB values and estimated GMMs');

% run segmentation based on GMM
lab_seg = segmentation_gmm(img, lab_in, NUM_COMPS, KMEANS_ITER);

figure();
imshow(compose_labeled_image(img, lab_seg));
title('Image and the final segmentation');
