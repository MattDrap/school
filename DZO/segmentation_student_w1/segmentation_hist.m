function lab_out = segmentation_hist(img, lab_in, num_bins, sigma)
% Segment the grayscale image based on various statistical properties
% of the foreground and background pixel intensities. The probability
% distributions of pixel intensities are modeled using histograms.
% The histograms are constructed from the initial partial labeling.
%
% Input:
%   img [HxW (double)] input grayscale image; intensities are from [0, 1]
%   lab_in [HxW (double)] initial labeling of pixels; label 0 denotes
%     unknown pixel, label 1 foregroung, label 2 background
%   num_bins [1x1 (double)] number of histogram bins
%   sigma [1x1 (double)] standard deviation of Gaussian used for histogram
%     smoothing
%
% Output:
%   lab_out [HxW (double)] output labeling of pixels; label 1 denotes
%     foregroung pixel, label 2 background

% TODO: Replace with your own implementation.
forpdf = hist_pdf(img(lab_in == 1), num_bins, sigma);
backpdf = hist_pdf(img(lab_in == 2), num_bins, sigma);

pfor = hist_prob(img(:)', forpdf);
pback = hist_prob(img(:)', backpdf);
lab_out = 2 * ones(size(lab_in));
lab_out(pfor > pback) = 1;

end
