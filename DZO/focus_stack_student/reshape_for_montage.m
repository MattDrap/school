function ims = reshape_for_montage(cell_of_ims)
% function ims = reshape_for_montage(cell_of_ims)
%
% INPUT: 
% cell_of_ims: 1 x imN cell storing images (one cell each). 
%    all images have the same size, M x N x C.
% OUTPUT: 
% ims: M x N x C x imN  matrix such that ims(:,:,:,k) = cell_of_ims{k}.
%
% Typical usage: 
% 
% montage(reshape_for_montage(cell_of_ims))

imN = numel(cell_of_ims); 
[M, N, C] = size(cell_of_ims{1}); 
ims = zeros(M, N, C, imN); 
for k=1:imN 
    ims(:,:,:,k) = cell_of_ims{k}; 
end


