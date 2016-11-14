function [idxs, dists] = nearest(means, data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

idxs = zeros(1, size(data, 2));
dists = ones(1, size(data, 2))*Inf;

for i = 1:size(means, 2)
    D = sqrt( sum((repmat(means(:, i), 1, size(data, 2)) - data).^2) );
    ind = dists > D;
    dists(ind) = D(ind);
    idxs(ind) = i;
end

end

