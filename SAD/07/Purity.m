function pur=Purity(labels,clusters)
% Computes the purity of clustering assignment of points with a known annotation
% The function assumes there are exactly 2 clusters.
%
% Input: 
%   labels = vector of 1s and 2s, which denote the result of clustering algorithm
%   points = vector of 1s and 2s of the same size, with the correct annotation

if size(labels,1)~=size(clusters,1)
  warning('Vector of labels and annotations have different length.')
end

correct=max(sum(labels==clusters),sum(labels~=clusters));
pur=correct/size(labels,1);