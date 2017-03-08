function a = sigma(z, activation, bias)
% activation function
%
% INPUTS:
%   z: N x M input data
%   activation: activation function string ['relu' 'nrelu' 'softplus' 'sigmoid' 'linear' 'tanh']
%   bias: bias for 'nrelu'
% OUTPUTS:
%   a: N x M activation function of input data

if strcmp(activation, 'relu')
    a = max(0, z);
elseif strcmp(activation, 'nrelu')
    if nargin<3
        bias = randn(size(z));
    end
    a = max(0, z + bias);
elseif strcmp(activation, 'softplus')
    a = log(1+exp(z));
elseif strcmp(activation, 'sigmoid')
    a = 1./(1+exp(-z));
elseif strcmp(activation, 'linear')
    a=z;
elseif strcmp(activation, 'tanh')
    a=tanh(z);
end

end
