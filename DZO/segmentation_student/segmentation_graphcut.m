function lab_out = segmentation_graphcut(img, lab_in, ...
	num_comps, kmeans_iter, neighborhood_type, lambda1, lambda2)
% Segment the RGB image using the graphcut algorithm. The probability
% distributions (GMMs) of background and foreground colors are constructed
% from the partial input labeling.
%
% Input:
%   img [HxWx3 (double)] input RGB image; all RGB channels are from [0, 1]
%   lab_in [HxW (double)] initial labeling of pixels; label 0 denotes
%     unknown pixel, label 1 foregroung, label 2 background
%   num_comps [1x1 (double)] number of clusters to be found by k-means
%     algorithm and also number of GMM components
%   kmeans_iter [1x1 (double)] maximum number of k-means iterations
%   neighborhood_type [1x1 (double)] type of the pixel neighborhood
%     (4-connected or 8-connected)
%   lambda1 [1x1 (double)] weight of Ising term in pairwise potentials
%   lambda2 [1x1 (double)] weight of dependent term in pairwise potentials
%
% Output:
%   lab_out [HxW (double)] output labeling of pixels; label 1 denotes
%     foregroung pixel, label 2 background

% convert image to list of RGB triples
[h, w, c] = size(img);
rgb = reshape(img, [h * w, c])';
% extract RGB triples labeled as foreground and background
rgb_f = rgb(:,lab_in(:)==1);
rgb_b = rgb(:,lab_in(:)==2);

comps_f = kmeans(rgb_f', num_comps, 'MaxIter', kmeans_iter);
[priors_f, means_f, covs_f] = gmm_estimation(rgb_f, comps_f);
comps_b = kmeans(rgb_b', num_comps, 'MaxIter', kmeans_iter);
[priors_b, means_b, covs_b] = gmm_estimation(rgb_b, comps_b);

mcost_unary = cost_unary(rgb, lab_in, priors_f, means_f, covs_f, ...
	priors_b, means_b, covs_b);
[pairs, dists] = build_neighborhood(h, w, neighborhood_type);
mcost = cost_pair(rgb, pairs, dists, lambda1, lambda2);

lab_out = graphcut(mcost_unary, pairs, mcost);
lab_out = reshape(lab_out, h, w);

% NOTE: Use provided function lab = graphcut(cost_unary, pairs, cost_pair)
%   in order to find the optimum labeling with respect to the specified
%   unary costs, pixel pairs and their costs.

end
