%
% [Y lambdas] = pca_basis(X)
%
% Function that computes the orthogonal basis of the principal components
% 
% Input:
%       X - Vectorized and centered images, of size [width*height, number_of_images]
% Output:
%       Y - Principal components (PC) sorted in decreasing order wrt the eigenvalues,
%           of size [width*height, number_of_images]
%       lambdas - Eigenvalores corresponging to the PC (decreasing order), 
%                 of size [width*height, 1]
%

function [Y lambdas] = pca_basis(X)
    
    % Trick for implementation
    % HERE YOUR CODE
    T = X'*X;
	[lambdas, Y] = eig(T);
    Y = X*Y;
    lambdas = diag(lambdas);
    
    % Sorting the eigen vectors and values
    
	% HERE YOUR CODE
    [lambdas, idcs] = sort(lambdas);
    lambdas = reverse(lambdas);
    Y = Y(:, idcs);
    Y = fliplr(Y);
    
    % Normalize the eigenvectors and eigenvalues

	% HERE YOUR CODE
    lambdas = lambdas ./ sum(lambdas);
    Y = normc(Y);
    % Fix the orientation of the principal components (due to different
    % behaviour in different Matlab versions)
    for I=1:size(Y, 2)
        idx = find(Y(:, I) ~= 0, 1, 'first');
        if Y(idx, I) < 0
            Y(:, I) = -Y(:, I);
        end
    end
end
