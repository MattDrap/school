function img = draw_pixels(img, pix_ind, color)
% Fill image pixels specified by their 1D index with the specified color.
% The function processes all channels of the image.

[h, w, c] = size(img);

num_channels = max(c, numel(color));

if c < num_channels
    img = repmat(img, [1 1 num_channels]);
end

for i = 1:num_channels
    ind_i = (i - 1) * h * w + pix_ind;
    img(ind_i) = color(i);
end

end
