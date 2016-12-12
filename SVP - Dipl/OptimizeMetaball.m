function [ err ] = OptimizeMetaball( probGT, probIm, radius, density, center, par )
%OptimizeMetaball Optimization of metaball parameters
%   Detailed explanation goes here

[subGT, new_center] = CropSat(probGT, center, radius);

subprob = CropSat(probIm, center, radius) ;
if size(density, 1) > 1
    density = density';
end
CImage = GenCloudImage(subGT, double( [new_center, radius, density]), par);

sqerr = sum( ((double(subprob(:)) / 255 - double(CImage(:)))/255).^2 ) / (size(subprob, 1) * size(subprob, 2)) ;
maxerr  = max(abs(double(subprob(:))/255 - double(CImage(:))/255));
%err = 0.5 * sqrt(sqerr) + 0.5 * maxerr;
err = maxerr;
end

