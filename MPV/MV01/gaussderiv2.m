function [ dxx, dxy, dyy ] = gaussderiv2( in, sigma )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
G = gaussfilter(in, sigma);

dx = conv2(1, [1,0, -1]/2, G, 'same');

dxx = conv2(1, [1, -2, 1], G, 'same');
dxy = conv2([1,0, -1]/2, 1, dx, 'same');
dyy = conv2([1, -2, 1], 1, G, 'same');
end

