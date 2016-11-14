function vertex_cost = seam_cost_standard(img, mask_delete, mask_protect)
% Compute vertex costs for seam carving task. The vertex costs for
% individual pixels are based on the estimated image gradient.
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
%     on the estimated image gradient and binary masks specifying pixels
%     to be deleted and protected

% estimate partial derivatives and compute vertex_cost

if exist('mask_delete', 'var')
    % modify vertex_cost of pixels to be deleted
end

if exist('mask_protect', 'var')
    % modify vertex_cost of protected pixels
end

end
