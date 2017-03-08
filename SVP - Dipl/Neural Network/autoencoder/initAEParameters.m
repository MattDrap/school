function [theta thetaSize] = initAEParameters(numvis, numhid, b)
% Initializes the parameters for an auto-encoder. 
%
% INPUTS:
%   numvis: number of visible units (input units)
%   numhid: number of hidden units
%   b: bias offset for b1 (use if ReLu activation function)
% OUTPUTS:
%   theta: vector of model parameters
%   thetaSize: structure of weights and biases

if nargin<3
    b=0;
end

%We initialize the biases b_i to zero, and the weights W^i to random 
% numbers drawn uniformly from the interval 
% [ -sqrt(6/(n_in+n_out+1)) , sqrt(6/(n_in+n_out+1)) ]
% where n_in is the fan-in (the number of inputs feeding into a node) and 
% nout is the fan-in (the number of units that a node feeds into). This
% initiliazation is better than randomly drawn values around 0. 
r1  = sqrt(6) / sqrt(numvis+numhid+1);
r2  = sqrt(6) / sqrt(numhid+numvis+1);
W1 = 1*rand(numhid, numvis)*2*r1 - r1;
W2 = 1*rand(numvis, numhid)*2*r2 - r2;
%W1 = 0.01*randn(numhid, numvis);
%W2 = 0.01*randn(numvis, numhid);
b1 = b*ones(numhid, 1);
b2 = zeros(numvis, 1);

% Convert weights and bias gradients to the vector form.
% This step will "unroll" (flatten and concatenate together) all 
% your parameters into a vector, which can then be used with minFunc. 
theta = [W1(:) ; W2(:) ; b1(:) ; b2(:)];
thetaSize = [size(W1); size(W2); size(b1); size(b2)];

end

