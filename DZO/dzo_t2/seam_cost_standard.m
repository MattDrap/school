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

if size(img, 3) > 1
   gray = rgb2gray(img); 
else
   gray = img;
end
sobel_vertical = [1/8, 0, -1/8;
                  1/4, 0, -1/4;
                  1/8, 0, -1/8];
sobel_horizontal = [1/8, 1/4, 1/8;
                    0, 0, 0;
                    -1/8, -1/4, -1/8];
vertex_cost1 = conv2(gray, sobel_vertical, 'same');
vertex_cost2 = conv2(gray, sobel_horizontal, 'same');

vertex_cost = abs(vertex_cost1) + abs(vertex_cost2);

if exist('mask_delete', 'var')
    % modify vertex_cost of pixels to be deleted
    vertex_cost(mask_delete) = size(img, 1) * -2;
end

if exist('mask_protect', 'var')
    % modify vertex_cost of protected pixels
    vertex_cost(mask_protect) = size(img, 1) * 2;
end
end
