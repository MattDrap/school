function [bin_centers, h, cdf] = image_hist_cdf(im, Nbins)
% function [bin_centers, h, cdf] = image_hist_cdf(im, Nbins)
% INPUT: 
% im: image is assumed to be of float type (single or double) 
%   and in range <0, 1>. 
%
% Nbins: required number of bins of histogram. Must be >1.
%
% OUTPUT: 
% 
% the bins have uniform widths, the first and last ones are at
% 0 and 1, respectively.
% 
% bin_centers: locations of bins. 
% h: counts in histogram bins 
% cdf: cumulative distribution function. sum(cdf) = 1. 

bin_centers = linspace(0, 1, Nbins); 
h = hist(im(:), bin_centers); 
cdf = cumsum(h); cdf=cdf/cdf(end); 

