function [cost, grad, indCost] = softmaxCost(theta, numClasses, inputSize, lambda, data, labels)
% Cost function for softmax classifier
% 
% INPUTS:
%   theta: Vector of all softmax model parameters
%   numClasses: number of classes 
%   inputSize: the size N of the input vector
%   lambda: weight decay parameter
%   data: N by M data matrix, example per column
%   labels: 1 by M label vector
% OUTPUTS:
%   cost: scalar of cost function, J
%   grad: vector of all updated softmax model parameters
%   indCost: vector of individual costs for each term in the cost function

theta = reshape(theta, numClasses, inputSize);
numCases = size(data, 2);
groundTruth = full(sparse(1:numCases, labels, 1, numCases, numClasses))'; % convert to K x M matrix

% % Move to GPU
% theta = gpuArray(theta);
% data = gpuArray(data);
% groundTruth = gpuArray(groundTruth);

% Calculate h
h = theta*data;
h = bsxfun(@minus, h, max(h, [], 1));
h = exp(h);
h = bsxfun(@rdivide, h, sum(h));

% Compute cost
sqerrterm = -1/numCases*sum(sum(log(h).*groundTruth));
weightdecayterm = lambda/2*sum(sum(theta.^2));
cost = sqerrterm + weightdecayterm;
indCost = [sqerrterm weightdecayterm];

% Compute derivatives
thetagrad = -1/numCases*(groundTruth-h)*data' + lambda*theta;

% ------------------------------------------------------------------
% Unroll the gradient matrices into a vector for minFunc
grad = thetagrad(:);

% Move back to CPU
% grad = gather(grad);
% cost = gather(cost);

end

