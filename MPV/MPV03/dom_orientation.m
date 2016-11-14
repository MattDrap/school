function angle=dom_orientation(img)
%dom_orientation Summary of this function goes here
%   Detailed explanation goes here
[height, width] = size(img);

nbins = 180;
sigma = 1;
[dx, dy] = gaussderiv(img, sigma);
orientation = atan2(dy, dx);
magnitude = sqrt(dx.^2 + dy.^2);



gx = gauss(-width/2:width/2-1, width/3);
gy = gauss(-height/2:height/2-1, height/3);
g = gy' * gx;

w_magnitude = magnitude .* g;

histogram = zeros(nbins, 1);
w_mags = w_magnitude(:);
orients = nbins*(orientation(:)+pi)/(2*pi);
orients = orients + 1;

bad_inds = (isnan(orients));
orients(bad_inds) = [];
w_mags(bad_inds) = [];

for i = 1:size(orients)
    ind = floor(orients(i));
    fract = orients(i) - ind;
    if ind > nbins
        continue
    end
    
    histogram(ind) = histogram(ind) + (1-fract) * w_mags(i);
    if ind + 1 > nbins
        histogram(1) = histogram(1) + (fract) * w_mags(i);
    else
        histogram(ind + 1) = histogram(ind + 1) + (fract) * w_mags(i);
    end
     
    %histogram(ind) = histogram(ind) + w_mags(i);
end
smooth_hist = conv(histogram', gauss(-3:3, 1), 'same');
[x, angle]=max(smooth_hist);
angle=(((angle-1)/nbins)*2*pi)-pi;

end