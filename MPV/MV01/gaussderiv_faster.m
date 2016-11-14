function [ dx, dy ] = gaussderiv_faster( in, sigma )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    G = gaussfilter(in, sigma);
    dx = conv2(1, [1,0,-1]/2, G, 'same');
    dy = conv2([1,0,-1]/2, 1, G, 'same');
end

