function [stack] = stack_pyrs(pyrs)
% function [stack] = stack_pyrs(pyrs)
%
% INPUT: 
%   pyrs: 1 x pyrN cell array storing pyramids.
%         It is assumed that all pyramids 
%         have matching sizes in all layers, that is, 
%           size(pyrs{k}.residuals{m}) == size(pyrs{l}.residuals{m})
%           ( for all k, l = 1,2,..pyrK and all m=1,2,..,layerN) 
%         and 
%           size(pyrs{k}.bottom_layer) == size(pyrs{l}.bottom_layer)
%           ( for all k, l)
% OUTPUT: 
%   stack: a structure with field 'residuals' and 'bottom_layer'. 
%          (the same fields as a pyramid). 
%          stack.residuals{m} stacks the corresponding residuals 
%             from all pyramids. That is, if 
%             [M, N] = size(pyrs{1}.residuals{m})
%             then stack.residuals{m} is an M x N x pyrN matrix. 
%          Similarly, stack.bottom_layer is a stack of bottom
%          layers of all pyramids. 

pyrN = numel(pyrs); 
layerN = numel(pyrs{1}.residuals); 
stack = struct('residuals', {cell(1, layerN)}, 'bottom_layer', []); 

% allocate storage: 
pyr = pyrs{1}; 
for l = 1:layerN
    stack.residuals{l} = zeros( [size(pyr.residuals{l}), pyrN] ) ; 
end
stack.bottom_layer = zeros([size(pyr.bottom_layer), pyrN]); 

% fill the stack with values: 
for k = 1:pyrN
    pyr = pyrs{k}; 
    for l = 1:layerN
        stack.residuals{l}(:, :, k) = pyr.residuals{l}; 
    end
    stack.bottom_layer(:,:,k) = pyr.bottom_layer; 
end
