function [optTheta Jtrain Jval] = minFuncSGD(funObj, theta, thetaSize, X, options, parameters, Xval)
% Stochastic Gradient Descent (SGD) for auto-encoder.
%
% INPUTS:
%   funObj: a pointer to a cost function
%   theta: vector of model parameters
%   thetaSize: structure of weights and biases
%   X: N X M training data matrix
%   options: optimizer hyper parameters
%   parameters: auto-encoder hyper parameters
%   Xval: N X M validation data matrix

% Default values
if ~isfield(parameters, 'useGPU'); parameters.useGPU = 0; end
if ~isfield(parameters, 'lambda'); parameters.lambda = 0; end
if ~isfield(parameters, 'beta'); parameters.beta = 0; end
if ~isfield(parameters, 'L1'); parameters.L1 = 0; end
if ~isfield(options,'useMomentum'); options.useMomentum = 1; end
if ~isfield(options, 'useGPU'); options.useGPU = 0; end

if isfield(parameters, 'trainlabels')
    parameters.labels = parameters.trainlabels;
end

if options.useGPU || parameters.useGPU
    device = gpuDevice(1);
    device.reset();
end

% Useful parameters
learningRateDecay = 0.01;
numepochs = options.numepochs;
batchsize = options.batchsize;
learningRate = options.learningRate;
numPatches = size(X,2);
numiters = floor(numPatches/batchsize);

% Momentum
if options.useMomentum
    momentum = 0.9;
    mom = 0.5;
else
    momentum = 0;
    mom = 0;
end
velocity = zeros(size(theta));

% Store and reset penalty term parameters
lambda = parameters.lambda;
beta = parameters.beta;
L1 = parameters.L1;
parameters.lambda = 0;
parameters.beta = 0;
parameters.L1 = 0;
% valparameters = parameters;
% valparameters.beta = 0;
% valparameters.lambda = 0;
% valparameters.L1 = 0;
% valparameters.useDropout = 0;
% valparameters.useDenoising = 0;

% Initialize variables
cost = zeros(numiters,1);
[~, ~, temp] = funObj(theta, thetaSize, X(:,1), parameters);
indCost = zeros(numiters, length(temp));
Jtrain = zeros(numepochs, 1);
Jval = zeros(numepochs, 1);
if options.useGPU
    theta = gpuArray(theta);
    X = gpuArray(X);
    velocity = gpuArray(velocity);
    Jtrain = gpuArray(Jtrain);
    Jval = gpuArray(Jval);
    Xval = gpuArray(Xval);
    cost = gpuArray(cost);
    indCost = gpuArray(indCost);
end

for epoch = 1:numepochs
    ticstart = tic;
    
    if options.useDecayLearningRate
        learningRate = options.learningRate/(1+learningRateDecay*epoch);
    end
    
    k = randperm(numPatches);
    
    for iter = 1:numiters
        
        if isfield(parameters, 'trainlabels')
            parameters.labels = parameters.trainlabels(k(1+(iter-1)*batchsize:iter*batchsize));
        end
        
        [cost(iter), grad, indCost(iter,:)] = funObj(theta, thetaSize, ...
            X(:,k(1+(iter-1)*batchsize:iter*batchsize)), parameters);
        
        if options.useMomentum % With momentum
            velocity = mom * velocity + learningRate * grad;
            theta = theta - velocity;
        else % Without momentum
            theta = theta - learningRate * grad;
        end

    end
    
    if epoch > 5
        mom = momentum;
    end;
    
    % Activate penalty terms
    if epoch > 5
        parameters.lambda = lambda;
        parameters.beta = beta;
        parameters.L1 = L1;
    end;
    
    % Calculate Jtrain and Jval
    Jtrain(epoch) = mean(cost);
    
    % Calculate Jval
    if exist('Xval','var')
        if isfield(parameters, 'vallabels')
            [pred, ~] = softmaxPredict(reshape(theta, thetaSize(1,:)), Xval);
            Jval(epoch) = mean(pred==parameters.vallabels);
        else
            [W1 W2 b1 b2] = theta2params(theta, thetaSize);
            h = sigma(bsxfun(@plus, W1 * Xval, b1), parameters.activation{1})*(0.5*parameters.useDropout+(1-parameters.useDropout));
            Xvalrec = sigma(bsxfun(@plus, W2 * h, b2), parameters.activation{2});
            Jval(epoch) = mean(mean((Xval-Xvalrec).^2));
        end
    end
    
    %Plot progress
    if options.plotProgress
        plotProgress(theta, thetaSize, X, parameters)
    end
    
    %     % Reset "dead" hidden units
    %     [W1 W2 b1 b2] = theta2params(theta, thetaSize);
    %     h = sigma(bsxfun(@plus, W1 * X, b1), parameters.activation{1})*(0.5*parameters.useDropout+(1-parameters.useDropout));
    %     resunits = find((sum(h,2)==0)==1);
    %     numvis = size(W1,2);
    %     numhid = length(resunits);
    %     r1  = sqrt(6) / sqrt(numvis+numhid+1);
    %     r2  = sqrt(6) / sqrt(numhid+numvis+1);
    %     W1(resunits,:) = 1*rand(numhid, numvis)*2*r1 - r1;
    %     W2(:,resunits) = 1*rand(numvis, numhid)*2*r2 - r2;
    %     b1(resunits) = 0;
    %     theta = [W1(:); W2(:); b1(:); b2(:)];
    
    fprintf(['Batch %i/%i %0.3f %0.3f\t' repmat('%0.2f ', 1, size(indCost,2)) ' Simtime: %0.1f\n'], epoch, numepochs, Jtrain(epoch), Jval(epoch), mean(indCost,1), toc(ticstart));
    
end

if options.useGPU
    optTheta = gather(theta);
    Jtrain = gather(Jtrain);
    Jval = gather(Jval);
else
    optTheta = theta;
end


end