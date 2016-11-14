function [vertex_cost, topleft_cost, top_cost, topright_cost] = ...
    seam_cost_forward(img, mask_delete, mask_protect)
% Compute vertex costs for seam carving task. The edge costs are based on
% potentially carved pixels. The vertex costs ensure deletion or protection
% of the desired pixels.
%
% Input:
%   img [MxNx3 (double)] input RGB image
%   mask_delete [MxN (logical)] matrix specyfing pixels for which vertex
%     cost must be low enough to ensure their priority carving
%   mask_protect [MxN (logical)] matrix specyfing pixels for which vertex
%     cost must be low enough to ensure their priority carving
%
% Output:
%   vertex_cost [MxN (double)] vertex costs for individual pixels based on
%     the deletion and protection masks
%   topleft_cost [MxN (double)] topleft_cost(i,j) =
%     ||img(i,j+1) - img(i,j-1)|| + ||img(i-1,j) - (i,j-1)||
%   top_cost [MxN (double)] top_cost(i,j) = ||img(i,j+1) - img(i,j-1)||
%   topright_cost [MxN (double)] topright_cost(i,j) =
%     ||img(i,j+1) - img(i,j-1)|| + ||img(i-1,j) - img(i,j+1)||

[h, w, ~] = size(img);

% add code for computing topleft_cost, top_cost and topright_cost

% default vertex_cost is zero
vertex_cost = zeros(h, w);

if exist('mask_delete', 'var')
    % modify vertex_cost of pixels to be deleted
end

if exist('mask_protect', 'var')
    % modify vertex_cost of protected pixels
end

end
