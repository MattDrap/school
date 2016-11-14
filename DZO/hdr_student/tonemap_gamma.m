function im = tonemap_gamma(hdr, gamma)
%TONEMAP_GAMMA Tonemapping via gamma correction
%
% im = tonemap_gamma(hdr, gamma)
%

im = hdr - min(hdr(:));
im = im ./ max(im(:));

hsv = rgb2hsv(im);
hsv(:,:,3) = hsv(:,:,3).^gamma;
im = hsv2rgb(hsv);

end
