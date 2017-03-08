function optTheta = softmaxTrain(inputData, labels, maxIter, lambda, verbose, numClasses, theta)
% Train a softmax model with the given parameters on the given data.
%
% INPUTS:
%   inputData: N by M data matrix, example per column
%   labels: 1 by M label vector
%   maxIter: number of iterations (default: 400)
%   lambda: weight decay parameter (default: 1e-4)
%   verbose: display cost after each iteration (default: 0)
%   numClasses: number of classes (default: length(unique(labels)) )
%   theta: Vector of all softmax model parameters (default: theta is reset)
% OUTPUTS: 
%   optTheta: Vector of all updated softmax model parameters

inputSize = size(inputData,1);

if nargin<=2; maxIter=400; end
if nargin<=3; lambda=1e-4; end
if nargin<=4; verbose = 0; end
if nargin<=5; numClasses = length(unique(labels)); end
if nargin<=6; theta = 0.005 * randn(numClasses * inputSize, 1); else theta = theta(:); end

% Set options
options.maxIter = maxIter;
if verbose; options.display = 'on'; else options.display = 'off'; end
options.Method = 'lbfgs'; %

% Convert data if necessary
if isa(labels,'single'); labels = double(labels); end
if isa(inputData,'single'); inputData = double(inputData); end

% Train softmax model
optTheta = minFunc( @(p) softmaxCost(p, numClasses, inputSize, lambda, inputData, labels), theta, options);

% Reshape 
optTheta = reshape(optTheta, numClasses, inputSize);

end
