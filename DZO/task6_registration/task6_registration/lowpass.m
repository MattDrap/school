function [im_out] = lowpass(im, sigma)

% boundary conditions: make them reflective 
hsize = ceil(sigma*5);
if ~mod(hsize, 2) hsize = hsize + 1; end; 

f = fspecial('gauss', [1, hsize], sigma); 

% enlarge the image by reflecting it around borders: 
% enlarge by b: 

im = conv2(f, f, im,  'same');  
% adjust for different valid neighborhood sizes: 
valid = conv2(f, f, ones(size(im)),  'same');

im_out = im./valid; 
