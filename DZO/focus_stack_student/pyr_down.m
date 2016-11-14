function [lower_layer, residuals] = pyr_down(upper_layer) 
% function [lower_layer, residuals] = pyr_down(upper_layer) 
% INPUT: 
%   upper_layer: an MxN array. 
% OUTPUT: 
%   lower_layer: a reduced (downscaled) form of upper_layer, of size 
%                ceil(M/2) x ceil(N/2)
%   residuals = difference between upper_layer and expanded 
%               (upscaled) form of lower_layer.
% (see code for details) 

lower_layer = im_down(upper_layer); 
residuals = upper_layer - im_up(lower_layer, size(upper_layer)); 
