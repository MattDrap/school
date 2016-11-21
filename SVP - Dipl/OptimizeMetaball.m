function [ err ] = OptimizeMetaball( probGT, probIm, radius, density, center, par )
%OptimizeMetaball Optimization of metaball parameters
%   Detailed explanation goes here

diameter = 2 * radius;

ymin = floor(center(1) - radius);
xmin = floor(center(2) - radius);
subGT = imcrop(probGT, [xmin, ymin, diameter, diameter]);

subprob = imcrop(probIm, [xmin, ymin, diameter, diameter]) ;
CImage = GenCloudImage(subGT, double( [ceil(size(subprob, 2)/2), ceil(size(subprob, 1)/2), radius, density]), par);

sqerr = sum( ((double(subprob(:)) / 255 - double(CImage(:)))/255).^2 ) / (size(subprob, 1) * size(subprob, 2)) ;
maxerr  = max(abs(double(subprob(:))/255 - double(CImage(:))/255));
err = 0.5 * sqrt(sqerr) + 0.5 * maxerr;
%err = sqerr;
end

