function showim_hist_cdf(im)
% function showim_hist_cdf(im)
% shows the image im, its histogram and CDF.

figure;
subplot(2,2,1);
image(repmat(im, [1 1 3]));
axis image off;

Nbins = 256;
[bin_centers, h, cdf] = image_hist_cdf(im, Nbins);
subplot(2,2,2);
plot(bin_centers, h);
title('image histogram');
xlabel('intensity');
ylabel('counts');

subplot(2,2,3);
plot(bin_centers, cdf);
title('intensity CDF');
xlabel('intensity');

