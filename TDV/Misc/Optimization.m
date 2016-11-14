function [ dist ] = Optimization(line ,points )
%OPTIMIZATION Summary of this function goes here
%   Detailed explanation goes here
line = line/norm(line(1:2));    %line = line/norm(line);
dists = line'*points;           %dists = (line' * points).^2;
dist = sum(dists.^2);
end

