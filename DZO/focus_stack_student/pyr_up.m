function [upper_layer] = pyr_up(lower_layer, residuals) 
% function [upper_layer] = pyr_up(lower_layer, residuals) 
%
% The following holds for an image im: 
% [g, l] = pyr_down(im); 
% im2 = pyr_up(g, l); 
% max(abs(im2(:) - im(:))) is low (typically < 1e-14). 

% Implement me: 
%upper_layer = zeros(size(residuals));
upper_layer = im_up(lower_layer, size(residuals)) + residuals;


