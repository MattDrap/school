function W = BuildEpsilonGraph(S,eps)

% BuildEpsilonGraph Creates an epsilon-neighbourhood matrix from a similarity matrix
%
% W = BuildEpsilonGraph(S,eps) sets all items to zero that are smaller than epsilon
%   
% Input:
%   S = similarity matrix, squared, symmetric, without negative values
%   eps = minimum value of epsilon to be retained

if (size(S,1) ~= size(S,2))
  error('Matrix is not squared!')
end

n = size(S,1);  

% Avoid loops
for it=1:n
  S(it,it) = 0; 
end
 
W = (S >= eps) .* S; 
  
   
  
