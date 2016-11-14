function pdf = hist_pdf(x, num_bins, sigma)
% Create histogram of input data samples having the specified number of
% bins, smooth by convolution with Gaussian and normalize to valid PDF.
%
% Input:
%   x [1xN (double)] N input data samples from the interval [0, 1]
%   num_bins [1x1 (double)] number of histogram bins
%   sigma [1x1 (double)] standard deviation of Gaussian used for histogram
%     smoothing
%
% Output:
%   pdf [1xnum_bins (double)] PDF estimated from smoothed and normalized
%     histogram of input data samples

% TODO: Replace with your own implementation.
% NOTE: You are encouraged to use the following functions:
xbins = linspace(0, 1, num_bins);
H = hist(x, xbins);
hsize = floor(5*sigma/2)*2 + 1;
hsize = [1 , hsize];
G = fspecial('gaussian', hsize, sigma); %choose filter size as the smallest
                                      %odd integer bigger or equal to 5*sigma
pdf = conv(H, G, 'same');

pdf = pdf./sum(pdf);

end
