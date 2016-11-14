function [im_out] = im_down(im) 
% function [im_out] = im_down(im) 
%
% INPUT: 
%   im: M x N array
% OUTPUT: 
%   im_out: ceil(M/2) x ceil(N/2) array obtained by
%           downscaling im. 
%           The resizing grid is such that the corner pixels
%           (upper left, upper right, bottom left, bottom right)
%           in both image match. 

[M, N] = size(im); 
[hM, hN] = deal( ceil(M/2), ceil(N/2) ); 

% blur (=avoid aliasing)
alpha = 0.375;
kernel1d = [1/4 - alpha/2, 1/4, alpha, 1/4, 1/4-alpha/2];
im_filtered = conv2(kernel1d, kernel1d, im, 'same'); 

% resample
[x, y] = meshgrid(linspace(1, N, hN), linspace(1, M, hM)); 
im_out = interp2(im_filtered, x, y); 
