function Z = lift_dimension(X)
    
% Lifts the dimensionality of the feature space from 2 to 5 dimensions
%
%   Parameters:
%       X - training samples in the original space (2xN matrix)
%
%   Returns:
%       Z - training samples in the lifted feature space (5xN vector)

Z = zeros(5,size(X,2));
for i = 1 : size(X,2)
    Z(:, i) = [X(1,i), X(2, i), X(1,i)^2, X(1,i) * X(2,i), X(2, i)^2];
end
end