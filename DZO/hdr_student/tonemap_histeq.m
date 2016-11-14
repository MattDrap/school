function im = tonemap_histeq(hdr)
%TONEMAP_HISTEQ Tonemapping via histogram equalization
%
% im = tonemap_histeq(hdr)
%

im = hdr - min(hdr(:));
im = im ./ max(im(:));

%% TODO: Implement me!
hsv = rgb2hsv(im);
H = histeq(hsv(:,:,3));
hsv(:,:,3) = H;
im = hsv2rgb(hsv);

%%

end
