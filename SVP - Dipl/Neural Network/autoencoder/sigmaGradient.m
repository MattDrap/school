function g = sigmaGradient(z, activation, bias)
% derivative of activation function
%
% INPUTS:
%   z: N x M input data
%   activation: activation function string ['relu' 'nrelu' 'softplus' 'sigmoid' 'linear' 'tanh']
%   bias: bias for 'nrelu'
% OUTPUTS:
%   g: N x M derivative of activation function of input data

if strcmp(activation, 'relu')
    g = double(z>0);
elseif strcmp(activation, 'nrelu')
    g = double(z+bias>0);
elseif strcmp(activation, 'softplus')
    g = 1./(1+exp(-z));
elseif strcmp(activation, 'sigmoid')
    a = 1./(1+exp(-z));
    g = a.*(1-a);
elseif strcmp(activation, 'linear')
    g = 1;
elseif strcmp(activation, 'tanh')
    g = 1 - tan(z).^2;
end


end