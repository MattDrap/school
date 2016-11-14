function im = tonemap_log(hdr)
%TONEMAP_LOG Tonemapping via logarithm
%
% im = tonemap_log(hdr)
%

im = hdr - min(hdr(:));
im = im ./ max(im(:));

%% TODO: Implement me!
hsv = rgb2hsv(im);
hsv(:,:,3) = log(hsv(:,:,3) + eps);
hsv(:,:,3) = (hsv(:,:,3) - min(min(hsv(:,:,3)))) ./ (max(max(hsv(:,:,3))) - min(min(hsv(:,:,3)))); 
im = hsv2rgb(hsv);

%%

end
