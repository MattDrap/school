function im = get_image(fname)
% function im = get_image(fname)
% INPUT:
%   'fname': a full path to the file 
% OUTPUT:
%   'im': a 2D matrix with an image. 
%       class(im) is double. 'im' is normalized to range [0, 1]. 
%       If 'fname' is a color image, the color channels are
%       averaged so that 'im' is grayscale. 

im = imread(fname); 

im = im2double(im); 
% that is equivalent to double(im)/255 for 8-bit images. 

% if the image has color channels, convert it to grayscale.
% average the channels: 
im = mean(im, 3); 
% (Note: could use 'im = rgb2gray(im)' which is peceptually more
%  accurate)



