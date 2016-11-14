function im_q = quantize_colors(im, k)
% im_q = quantize_colors(im, k)
%
% Image color quantization using the k-means clustering. The pixel colors
% are at first clustered into k clusters. Color of each pixel is then set
% to the mean color of the cluster to which it belongs to.
%
% Input:
%   im        .. Image whose pixel colors are to be quantized.
%
%   k         .. Required number of quantized colors.
%
% Output:
%   im_q      .. Image with quantized colors.


% Convert the image from RGB to L*a*b* color space
cform = makecform('srgb2lab');
im = applycform(im, cform);

[H, W, C] = size(im);
inds = randsample(H * W, 1000);
tempim = reshape(im, H*W, C);
tempim = double(tempim)./255;
tempim = tempim';
pixels = tempim(:, inds);
[c, means, sq_dists] = k_means(pixels, k, inf);

dists = zeros(k, H*W);
for i = 1:k
    d = bsxfun(@minus, tempim, means(:,i));
    dists(i, :) = sum(d.^2, 1);
end
[~, nc] = min(dists);
tempim = means(:, nc);
tempim = tempim .* 255;
tempim = uint8(tempim);
im_q = reshape(tempim', [H, W, C]);
% Convert the image from L*a*b* back to RGB
cform = makecform('lab2srgb');
im_q = applycform(im_q, cform);
