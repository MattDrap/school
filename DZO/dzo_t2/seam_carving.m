function [img_carved, seams] = seam_carving(img, direction, num_seams, ...
	cost_method, mask_delete, mask_protect)
% Incrementally carve seams from the given image taking the pixels to be
% deleted and pixels to be protected into an account. The direction and
% minimum number of seams can be also specified.
%
% Input:
%   img [MxNx3 (double)] input RGB image
%   direction [string] specifying direction of seams {'vertical',
%     'horizontal'} to be carved from the image
%   num_seams [int] minimum number of carved seams; the real number of
%     carved seams is determined so that all pixels marked for deletion
%     will be carved out
%   cost_method [string] specifying which cost function should be used for
%     vertices and edges {'standard', 'forward'}
%   mask_delete [MxN (logical)] mask denoting pixels to be deleted
%   mask_protect [MxN (logical)] mask denoting pixels to be protected
%
% Output:
%   img_carved [Mx(N-K)x3 or (M-K)xNx3 (double)] output RGB image having K
%     seams carved out
%   seams [MxK or KxN] matrix containing K vertical or horizontal seams
%     which have been carved out

img_carved = img;

% the following algorithm works with vertical seams only, so transpose the
% image it we want to carve horizontal seams
if strcmpi(direction, 'horizontal')
	img_carved = permute(img_carved, [2 1 3]);
	mask_delete = mask_delete';
	mask_protect = mask_protect';
end

[h, w, ~] = size(img_carved);

% determine number of seams to delete everything in the mask, use the
% desired number of seams and not to use more seams than columns
mask_delete_width = max(sum(mask_delete, 2));
num_seams = min(max(mask_delete_width, num_seams), w);

% carve vertical seams from the image and both masks iteratively
seams = zeros(h, num_seams);
for i = 1:num_seams
	% use the same dynamic programming procedure to find the shortest seam,
	% but with different vertex and edge costs (standard or forward)
	if strcmpi(cost_method, 'standard')
		vertex_cost = seam_cost_standard(...
			img_carved, mask_delete, mask_protect);
        seams(:,i) = dp_path(vertex_cost);
	else
		[vertex_cost, topleft_cost, top_cost, topright_cost] = ...
            seam_cost_forward(img_carved, mask_delete, mask_protect);
        seams(:,i) = dp_path(...
			vertex_cost, topleft_cost, top_cost, topright_cost);
	end
	
	% carve the currently found seam from the image and both masks
	img_carved = carve_seam(seams(:,i), img_carved);
	mask_delete = carve_seam(seams(:,i), mask_delete);
	mask_protect = carve_seam(seams(:,i), mask_protect);
end

% transpose the image back
if strcmpi(direction, 'horizontal')
	img_carved = permute(img_carved, [2 1 3]);
end

end
