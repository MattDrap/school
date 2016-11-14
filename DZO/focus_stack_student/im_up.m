function [im_out] = im_up(im, out_size) 
% function [im_out] = im_up(im, out_size) 
%
% INPUT: 
%   im: M x N array
%   out_size: 1 x 2 array. The required size of the upscaled image. 
%         It is assumed that out_size(1)>M, out_size(2)>N.
% OUTPUT: 
%   im_out: the resized image. 
%           The resizing grid is such that the corner pixels
%           (upper left, upper right, bottom left, bottom right)
%           in both image match. 
%

% Implement me: 

[M, N] = size(im); 
hM = out_size(1);
hN = out_size(2);


% resample
[x, y] = meshgrid(linspace(1, N, hN), linspace(1, M, hM)); 
im_out = interp2(im, x, y); 
