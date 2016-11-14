function [ err ] = OptimizeMetaball( probGT, probIm, radius, density, center, par )
%OptimizeMetaball Optimization of metaball parameters
%   Detailed explanation goes here

up_radius = radius + par.raise_crop;

row1 = floor(center(2) - (up_radius)/2);
col1 = floor(center(1) - (up_radius)/2);
subGT = imcrop(probGT, [row1, col1, up_radius, up_radius]);

subprob = imcrop(probIm, [row1, col1, up_radius, up_radius]) ;
CImage = GenCloudImage(subGT, double( [ceil(size(subprob, 2)/2), ceil(size(subprob, 1)/2), radius, density]), par);

err = sum( (subprob(:) - CImage(:)).^2 ) ...
    / (size(subprob, 1) * size(subprob, 2)) ;
end

