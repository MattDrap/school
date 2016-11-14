function [pairs, dists] = build_neighborhood(h, w, neighborhood_type)
% Build 4-connected or 8-connected neighborhood of pixels and compute
% their spatial distances. The pairs of neighboring pixels are determined
% by pairs of their 1D indices in the image grid.
%
% Input:
%   h [1x1 (double)] image height
%   w [1x1 (double)] image width
%   neighborhood_type [1x1 (double)] type of the neighborhood; it is equal
%     to 4 for 4-connected neighborhood (only vertically or horizontally
%     adjacent pixels are neighbors) or it is equal to 8 for 8-connected
%     neigborhood (also diagonally adjacent pixels are neigbhors)
%
% Output:
%   pairs [2xM (double)] M pairs of 1D indices of neighboring pixels; each
%     index is a number from the set {1, 2, ..., h * w} using the standard
%     Matlab order (all rows of the first column, second column, ...); each
%     pair of neighbors should be included only once, independently on
%     their order, i.e. if pixels t and s are neighbors then pairs should
%     include either the column [t;s] or [s;t], never both of them
%   dists [1xM (double)] M spatial Euclidean distances of neighboring
%     pixels; pair of vertically or horizontally adjacent pixels has
%     distance 1, diagonally adjacent pixels sqrt(2)


indices = ones(h+2,w+2) * -1;
ind_in = reshape(1:w*h, [h, w]);
indices(2:end-1, 2:end-1) = ind_in;
running = 1;
for i = 2:size(indices, 1) - 1
   for j = 2:size(indices, 2) - 1 
        pairs(:, running) = [indices(i,j), indices(i, j+1)];
        dists(running) = 1;
        running = running + 1;
        pairs(:, running) = [indices(i,j), indices(i+1, j)];
        dists(running) = 1;
        running = running + 1;
        if neighborhood_type > 4
            pairs(:, running) = [indices(i,j), indices(i+1, j-1)];
            dists(running) = sqrt(2);
            running = running + 1;
            pairs(:, running) = [indices(i,j), indices(i+1, j+1)];
            dists(running) = sqrt(2);
            running = running + 1;
        end
   end
end
to_remove = find(pairs(1,:) == -1);
index = [to_remove, find(pairs(2, :) == -1)];
pairs(:, index) = [];
dists(index) = [];
end
