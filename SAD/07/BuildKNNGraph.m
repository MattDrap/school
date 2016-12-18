function [ W ] = BuildKNNGraph( S, k )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if (size(S,1) ~= size(S,2))
  error('Matrix is not squared!')
end

n = size(S,1);

% Avoid self-loops
for it=1:n
  S(it,it) = 0; 
end


% Initialize the matrix
W = S; 

for it = 1:n
  % Sort the items
  [sorted_row, order] = sort(S(it,:), 'descend'); 
  % u vsech bod,u ktere nejsou mezi prvnimi k nuluj matici W
  W(it, order(k+1:end)) = 0;
  W(order(k+1:end), it) = 0;
end

end

