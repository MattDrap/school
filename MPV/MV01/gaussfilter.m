function [ out ] = gaussfilter( in, sigma )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
x = [-ceil(3.0*sigma):ceil(3.0*sigma)];
G = gauss(x, sigma);
G = G./sum(G);
out = conv2(G, G, in, 'same');
end

