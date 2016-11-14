function [x_low, x_high] = range_by_quantiles(cdf, p_low, p_high)
% function [x_low, x_high] = range_by_quantiles(cdf, p_low, p_high)
%
% cdf:   the CDF of an image. 
% 
% x_low is the highest intensity x for which CDF(x) <= p_low. 
%       If no such point exists, output x_low = 0.0. 
% 
% x_high is the lowest intensity x for which CDF(x) >= p_high. 
%       If no such point exists, output x_high = 1.0. 
%
% Example usage: 
% ==============
% Find x_low and x_high in order to subsequently map
% x_low -> 0 and x_high -> 1, discarding 1% of pixels 
% at both ends of intensity axis. 
% 
% Finding such x_low and x_high would require:
% 
% [x_low, x_high] = range_by_quantiles(cdf, 0.01, 0.99)

x = linspace(0, 1, length(cdf)); 
ix_low = find(cdf <= p_low, 1, 'last');
ix_high = find(cdf >= p_high, 1, 'first');
if isempty(ix_low)
    x_low = 0;
else
    x_low = x(ix_low);
end
if isempty(ix_high)
    x_high = 0;
else
    x_high = x(ix_high);
end
