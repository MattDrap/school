function out_pyr = pyrs_blend(stack, stack_weights)
% function out_pyr = pyrs_blend(stack, stack_weights)
% 
% INPUT: 
%    stack: stack of pyramids 
%    stack_weights: obtained from compute_weights function
% OUTPUT: 
%     out_pyr: a single pyramid obtained by weighted average of stack.

% Implement me: 
layerN = numel(stack.residuals); 
out_pyr = struct('residuals', {cell(1, layerN)}, 'bottom_layer', []);
average_layer = sum(stack_weights.bottom_layer.*stack.bottom_layer,3);
idx = 1;
residuals = cell(1, layerN);
for i = 1:layerN
     residuals{i} = sum(stack_weights.residuals{i} .* stack.residuals{i},3);
     idx = idx + 1;
end
out_pyr.residuals = residuals;
out_pyr.bottom_layer = average_layer;
