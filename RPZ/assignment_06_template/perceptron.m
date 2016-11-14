function [w, b] = perceptron(X, y, maxIterations)
    
% Implements the perceptron algorithm
% (http://en.wikipedia.org/wiki/Perceptron)
%   
%   Parameters:
%       X - training samples (DxN matrix)
%       y - training labels (1xN vector, contains either 1 or 2)
%
%   Returns:
%       w - weights vector (Dx1 vector)
%       b - bias (offset) term (1 double)
[D, N] = size(X);
ny = y;
ny(ny == 2) = -1;
NX = bsxfun(@times, ny, [ones(1,N);X]);
%NX = ny * [ones(1,N);X];
w = zeros(D+1,1);
fails = w'*NX <= 0;
for iter = 1 : maxIterations
    if sum(fails) == 0
        break;
    end
    idx = find(fails);
    w = w + NX(:,idx(1));
    fails = w'*NX <= 0;
end
if iter ~= maxIterations
    b = w(1);
    w = w(2:end);
else
    b = NaN;
    w = NaN;
end
end