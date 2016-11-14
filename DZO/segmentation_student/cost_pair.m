function cost = cost_pair(rgb, pairs, pair_dists, lambda1, lambda2)
% Compute pairwise costs for pairs of neighboring pixels. Each pair is
% determined by a pair of 1D indices in the image grid.
%
% Input:
%   rgb [3xN (double)] RGB values for N input pixels
%   pairs [2xM (double)] M pairs of 1D indices of neighboring pixels; each
%     index is a number from the set {1, 2, ..., N}, i.e. column index to
%     'rgb' matrix; pairs are output of the function 'build_neighborhood'
%   pair_dists [1xM (double)] M spatial Euclidean distances of pixel pairs;
%     pair_dists are output of the function 'build_neighborhood'
%   lambda1 [1x1 (double)] weight of Ising term in pairwise costs
%   lambda2 [1x1 (double)] weight of dependent term in pairwise costs
%
% Output:
%   cost [1xM (double)] costs for M neighboring pairs of pixels; it should
%     hold cost(i) = r(t,s) = r(s,t) where pairs(:,i) contains either [t;s]
%     or [s;t] (the order of pixel indices in pair is not important)

% TODO: Replace with your own implementation.
%cost = lambda1 * ones(size(pair_dists));
euclids = sqrt((rgb(1, pairs(1,:)) - rgb(1, pairs(2, :))).^2 ...
          + (rgb(2, pairs(1,:)) - rgb(2, pairs(2, :))).^2 ...
          + (rgb(3, pairs(1,:)) - rgb(3, pairs(2, :))).^2 );
Beta = 1/length(euclids) * sum(euclids);
cost = zeros(1, length(pair_dists));
for i = 1:length(pair_dists)
    cost(i) = lambda1 + lambda2/pair_dists(i) .* exp(-euclids(i)/(2*Beta));
end
end
