function cost = cost_unary(rgb, lab_in, priors1, means1, covs1, ...
	priors2, means2, covs2)
% Compute unary costs for the given RGB values using two estimated GMMs
% determined by their priors, means and covariances.
%
% Input:
%   rgb [3xN (double)] RGB colors of N=HxW input pixels
%   lab_in [HxW (double)] initial labeling of pixels; label 0 denotes
%     unknown pixel, label 1 foregroung, label 2 background
%   priors1 [1xK (double)] prior probabilities for foreground GMM
%   means1 [DxK (double)] mean vectors for foreground GMM
%   covs1 [DxDxK (double)] covariance matrices for foreground GMM
%   priors2 [1xK (double)] prior probabilities for background GMM
%   means2 [DxK (double)] mean vectors for background GMM
%   covs2 [DxDxK (double)] covariance matrices for background GMM
%
% Output:
%   cost [2xN (double)] unary costs for all input pixels; cost(1,:) are
%     costs for class 1 (foreground), cost(2,:) for class 2 (background)

% TODO: Replace with your own implementation.
cost = ones(2, size(rgb, 2));
rgb_f = rgb(:,lab_in(:)==1);
rgb_b = rgb(:,lab_in(:)==2);
pfor = gmm_prob(rgb_f, priors1, means1, covs1);
pback = gmm_prob(rgb_b, priors2, means2, covs2);

cost(1, lab_in(:) ~= 2) = -log(gmm_prob(rgb(:, lab_in(:) ~= 2), priors1, means1, covs1));
cost(2, lab_in(:) ~= 1) = -log(gmm_prob(rgb(:, lab_in(:) ~= 1), priors2, means2, covs2));
cost(1, lab_in(:) == 2) = inf;
cost(2, lab_in(:) == 1) = inf;
end
