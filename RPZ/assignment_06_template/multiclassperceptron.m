function [w, b] = multiclassperceptron(X, y, maxIterations)
    
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
NX = [ones(1,N);X];
maxClasses = max(unique(y));
means = zeros(maxClasses, D + 1);
for i = 1:maxClasses
    t = NX(:, y == i);
    means(i, :) = mean(t, 2);
end
w = means;
w(:, 1) = 0;
ww = w*NX;
[mw, iw] = max(ww);
fails = iw ~= y;
for iter = 1 : maxIterations
    if sum(fails) == 0
        break;
    end
    idx = find(fails);
    xt = NX(:, idx(1));
    
    right = y(idx(1));
    notright = ones(maxClasses, 1);
    notright(right) = 0;
    notright = logical(notright);
    nd = size(w(notright, :),1);
    w(notright, 2:end) = w(notright, 2:end) - repmat(xt(2:end)', nd, 1);
    w(right, 2:end) = w(right, 2:end) + xt(2:end)';
    w(notright, 1) = w(notright, 1) - 1;
    w(right, 1) = w(right, 1) + 1; 
    
    ww = w*NX;
    [mw, iw] = max(ww);
    fails = iw ~= y;
end
if iter ~= maxIterations
    b = w(:, 1);
    w = w(:, 2:end);
else
    b = ones(maxClasses, 1) * NaN;
    w = ones(maxClasses, D) * NaN;
end
end