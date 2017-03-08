function [cost, grad, indCost] = costAutoencoder(theta, thetaSize, X, parameters)
% Cost function for a 1-layered Auto-encoder.
%
% INPUTS: 
%   theta: A column vector of the parameters. [W1(:); W2(:); b1(:) b2(:)]
%   thetaSize: A 4x2 matrix where thetaSize(1,1) is the number of rows
% of W1 and thetaSize(1,2) is the number of columns in W1. thetaSize(2,:)
% is the number of rows and columns of W2 etc.
%   X: the N x M input matrix, where each column X(:, i) corresponds to one
% training example
%   y: an 1 x M vector containing the labels corresponding for the input data
%   parameters: A structure of all the parameters
% OUTPUTS:
%   cost: scalar of cost function, J
%   grad: vector of all updated auto-encoder model parameters
%   indCost: vector of individual costs for each term in the cost function

if ~isfield(parameters,'useGPU')
    parameters.useGPU = 0;
end

% Useful parameters
m = size(X, 2);

% Reshape theta to the network parameters
[W1 W2 b1 b2] = theta2params(theta, thetaSize);

% Get the parameters
lambda = parameters.lambda; % Weight decay penalty parameter
beta = parameters.beta; % sparsity penalty parameter
p = parameters.p; % sparsity activation parameter rho. 
L1 = parameters.L1; % L1-penalty on hidden activation
activation = parameters.activation; % Cell sruct of length two with 'linear', 'sigmoid', 'relu', 'softplus'

% Move from CPU to GPU
if parameters.useGPU
    W1 = gpuArray(W1);
    W2  = gpuArray(W2);
    b1  = gpuArray(b1);
    b2 = gpuArray(b2);
    X = gpuArray(X);
end

if parameters.useDenoising
    Xclean = X;
    X(rand(size(X))<0.2)=0;
end

if strcmp(activation{1}, 'nrelu')
    %rng('default')
    bias = randn(size(W1,1), m);
else
    bias = 0;
end

if parameters.useDropout
    %rng('default')
    delhid = rand(1, size(W1,1))<0.5;
    W1(delhid,:) = 0;
    W2(:, delhid,:) = 0;
    b1(delhid)=0;
end
    
% Feedforward
z2 = bsxfun(@plus,W1*X,b1);
a2 = sigma(z2, activation{1}, bias);
z3 = bsxfun(@plus,W2*a2,b2);
a3 = sigma(z3, activation{2});

if parameters.useDenoising
    X = Xclean;
end

% Square error cost
if strcmp(activation{2}, 'softplus')
    sqerrterm = mean(0.25*sum((a3-X).^4,1));
else
    sqerrterm = mean(0.5*sum((a3-X).^2,1));
end

% Weight decay cost
weightdecayterm = lambda/2*(sum(sum(W1.^2))+sum(sum(W2.^2)));

% Sparsity cost
if beta~=0
    pj = mean(a2,2);
    sparsitypenalty = beta * sum((p*log(p./pj)+(1-p)*log((1-p)./(1-pj))));
else
    sparsitypenalty = 0;
end

% Hidden activation L1-penalty cost
L1weightdecayterm = L1*sum(sum(a2,2));

% Total cost
cost = sqerrterm + weightdecayterm + sparsitypenalty + L1weightdecayterm;
indCost = [sqerrterm weightdecayterm sparsitypenalty L1weightdecayterm];

% Backpropagation
if strcmp(activation{2}, 'softplus')
    delta3 = -(X-a3).^3;
else
    delta3 = -(X-a3);
end
delta3 = delta3.*sigmaGradient(z3, activation{2});

delta2 = W2'*delta3;
if beta~=0
    delta2 = bsxfun(@plus, delta2, beta*(-p./pj + (1-p)./(1-pj)));
end
delta2 = delta2.*sigmaGradient(z2, activation{1}, bias);

% Update parameters
gradW2 = delta3*a2'/m + lambda*W2;
gradb2 = sum(delta3,2)/m;
gradW1 = delta2*X'/m + lambda*W1 + L1*sigmaGradient(z2, activation{1}, bias)*X';
gradb1 = sum(delta2,2)/m + L1*sum(sigmaGradient(z2, activation{1}, bias),2);

% Unroll the gradient matrices into a vector for the gradient method
grad =  [gradW1(:); gradW2(:); gradb1(:); gradb2(:)];

% Move back from GPU to CPU
if parameters.useGPU
    cost = gather(cost);
    grad = gather(grad);
    indCost = gather(indCost);
end


end





