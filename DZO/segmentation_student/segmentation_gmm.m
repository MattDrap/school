function lab_out = segmentation_gmm(img, lab_in, num_comps, kmeans_iter)
% Segment the RGB image based on various statistical properties
% of the foreground and background pixel colors. The probability
% distributions of RGB colors are modeled using mixture of Gaussians (GMM).
% The GMMs are constructed from the initial partial labeling.
%
% Input:
%   img [HxWx3 (double)] input RGB image; all RGB channels are from [0, 1]
%   lab_in [HxW (double)] initial labeling of pixels; label 0 denotes
%     unknown pixel, label 1 foregroung, label 2 background
%   num_comps [1x1 (double)] number of clusters to be found by k-means
%     algorithm and also number of GMM components
%   kmeans_iter [1x1 (double)] maximum number of k-means iterations
%
% Output:
%   lab_out [HxW (double)] output labeling of pixels; label 1 denotes
%     foregroung pixel, label 2 background

% TODO: Replace with your own implementation.
Find = repmat(lab_in == 1, [1,1,3]);
F = img(Find);
F = reshape(F, size(F, 1) / 3, 3);
comps_f = kmeans(F, num_comps, 'MaxIter', kmeans_iter);
[priors_f, means_f, covs_f] = gmm_estimation(F', comps_f);

Bind = repmat(lab_in == 2, [1,1,3]);
B = img(Bind);
B = reshape(B, size(B, 1) / 3, 3);
comps_b = kmeans(B, num_comps, 'MaxIter', kmeans_iter);
[priors_b, means_b, covs_b] = gmm_estimation(B', comps_b);

imdata = reshape(img, [size(img,1) * size(img, 2), 3]);
pfor = gmm_prob(imdata', priors_f, means_f, covs_f);
pback = gmm_prob(imdata', priors_b, means_b, covs_b);
lab_out = 2 * ones(size(lab_in));
lab_out(pfor > pback) = 1;

end
