function centers = k_meanspp(x, k)
% KMEANSPP - perform k-means++ initialization for k-means clustering.
%
% Input:
%   X - [DIMS x N] N input vectors of dimenionality DIMS
%   K - [int] number of k-means centers
%
% Output:
%   CENTERS - [DIMS x K] K proposed centers for k-means initialization

% Number of vectors
N = size(x, 2);
centers_num = 1;
centers = zeros(size(x, 1), k);
rand_num = random_sample(ones(1, N));
centers(:, centers_num) = x(:, rand_num);
while centers_num ~= k
    %distances
    sq_dists = zeros(centers_num, N);
    for i = 1:centers_num
        d = bsxfun(@minus, x, centers(:,i));
        sq_dists(i, :) = sqrt(sum(d.^2, 1));
    end
    val = min(sq_dists, [], 1);
    r = random_sample(val.^2);
    ncenter = x(:, r);
    centers(:, centers_num+1) = ncenter;
    centers_num = centers_num + 1;
end
