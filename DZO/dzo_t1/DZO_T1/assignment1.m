im = get_image('images/P.jpg');
Nbins = 256;
[bin_centers, h, cdf] = image_hist_cdf(im, Nbins);
showim_hist_cdf(im);
 
% get 1% and 99% quantile of CDF:
p_low = 0.01;
p_high = 0.99;
[x_low, x_high] = range_by_quantiles(cdf, p_low, p_high);
% Expected result:
% x_low = 0.1490
% x_high = 0.6431
 
% construct LUT:
lut = lut_from_range(x_low, x_high, Nbins);
 
% and display it:
figure();
plot(bin_centers, lut);
ylim([-0.2, 1.2]);
 
% apply it and show result:
im_stretched = transform_by_lut(im, lut);
showim_hist_cdf(im_stretched);