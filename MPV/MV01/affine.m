function [ out ] = affine( x1,y1, x2,y2,x3,y3 )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
    out = [x2 - x1, x3 - x1, x1;
           y2 - y1, y3 - y1, y1;
           0,      0,        1];

end

