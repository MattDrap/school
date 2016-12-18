function W = BuildDirectedKNNGraph(S,k)

% BuildDirectedKNNGraph Creates a matrix of an oriented kNN graph from a similarity matrix
%
% W = BuildDirectedKNNGraph(S,k) sets all but k nearest elements to zero
%   
% Input:
%   S = similarity matrix, squared, symmetric, without negative values
%   k = number of nearest neighbours that should be kept 

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
  [sorted_row,order] = sort(S(it,:), 'descend'); 
  % u vsech bod,u ktere nejsou mezi prvnimi k nuluj matici W
  W(it, order(k+1:end)) = 0;
end

  
