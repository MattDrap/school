function [ D ] = dgauss( x, sigma )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    D = -x.*exp(-x.^2/(2*sigma^2))./(sqrt(2*pi)*sigma^3);

end

