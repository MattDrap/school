function [ iso ] = isomap( X, dims, kdim )
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
%%
%Calculate Distances
N = size(X, 1);
dists = zeros(N,N);
for i = 1:N
    dists(i, :) = sqrt( sum( (repmat(X(i, :), N, 1) - X).^2, 2 ) )';
end
%%
%K-NN
F = dists;
INF = N*max(F(:));
for it = 1:N
  % Sort the items
  [~, order] = sort(dists(it,:), 'ascend'); 
  
  F(order(kdim+2:end), it) = INF;
end
F = min(F, F');
%%
%Floyd
for k = 1:N 
    F = min(F,repmat(F(:,k),[1 N])+repmat(F(k,:),[N 1])); 
end
iso = mypca(F, dims);