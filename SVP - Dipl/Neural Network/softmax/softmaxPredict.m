function [pred, h, prob] = softmaxPredict(theta, data)
% Calculates predictions, hypothesis, and probabilities for input data 
% given trained softmax weight matrix theta.
%
% INPUTS:
%   theta: weight matrix [numClasses x N] OR trained softmaxModel
%   data: N x M input matrix 
% OUTPUTS:
%   pred: 1 x M vector of predicted classes
%   h: K x M hypotesis matrix
%   prob: probabily matrix

if isstruct(theta)
    theta = theta.optTheta;
end

h = theta*data;
h = bsxfun(@minus, h, max(h, [], 1));
h = exp(h);
h = bsxfun(@rdivide, h, sum(h));

[prob, pred]=max(h,[],1);


end

