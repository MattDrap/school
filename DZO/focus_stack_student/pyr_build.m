function pyr = pyr_build(im, min_size) 
% function pyr = pyr_build(im, min_size) 
% builds a Laplacian pyramid for image im. 
%
% im: an MxN array. 
%
% pyr is a structure with fields: 
%     'residuals' : 1 x layerN cell of highpass components.
%          residuals{1} is the same size as im. 
%          residuals{2}, residuals{3}, etc. are progressively
%          (by a factor of 2) smaller.
%     'bottom_layer' : the last lowpass component 
%                  (layerN timesdownscaled version of the original image)
%
% min_size : number > 1. min_size is the limit on the size of last
%      residuals, residuals{layerN}. Pyramid construction
%      terminates when size of the lowpass component gets <=
%      min_size. 
%      Essentially, min_size then determines the number of layers 
%      in the pyramid, layerN.
%
% min_size is an optional parameter with default value 10. 

if ~exist('min_size') 
    min_size = 10; 
end

assert(min_size > 1)

g = im; 
pyr = struct('residuals', cell(1,1), 'bottom_layer', []); 

idx = 1;
while all( size(g) > min_size)
    [g, l] = pyr_down(g); 
    pyr.residuals{idx} = l; 
    idx = idx + 1; 
end
pyr.bottom_layer = g; 
