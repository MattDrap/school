function stack_weights = compute_weights(stack, exponent)
% function stack_weights = compute_weights(stack, exponent)
%
% INPUT: 
%   stack: the pyramid stack obtained from stack_pyrs(pyrs). 
%   exponent: a number > 0 
% OUTPUT:
%   stack_weights: same fields and sizes as stack. 
%        obtained from stack as follows: 
%        - stack_weights.residuals{m} = abs(pyr.residuals{m}).^exponent
%        - normalizing w.r.t. 3rd dimension
%
%        stack_weights.bottom_layer: uniform weights, 
%             normalized w.r.t. 3rd dimension 

layerN = numel(stack.residuals); 
elN = size(stack.bottom_layer, 3); 

stack_weights = struct('residuals', {cell(1, layerN)}, 'bottom_layer', []); 

% weights for the bottom layer: 
stack_weights.bottom_layer = ones(size(stack.bottom_layer)) / elN; 

% weights for the residuals: 
for l = 1:layerN 
    weights_ = abs(stack.residuals{l}).^exponent;

    % normalize them per - pixel: 
    sums = sum(weights_, 3); 

    % ensure safe normalization - if sums are too close to zero, do
    % not divide by them
    sums(sums < 1e-10) = 1; 
    weights_ = weights_./repmat(sums, [1, 1, size(weights_, 3)]);
    stack_weights.residuals{l} = weights_; 
end


