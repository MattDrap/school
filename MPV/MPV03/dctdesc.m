function dct=dctdesc(img,num_coeffs)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
[H, W] = size(img);
assert(num_coeffs <= H*W, 'Can ''t be greater');
D = dct2(img);
D = D - min(D(:));
D = D./max(D(:));

%%
% Amro's fast zig zag
% http://stackoverflow.com/questions/3024939/matrix-zigzag-reordering/3025478#3025478
ind = reshape(1:numel(D), size(D))';         
ind = fliplr( spdiags( fliplr(ind) ) );     %# get the anti-diagonals
ind(:,1:2:end) = flipud( ind(:,1:2:end) );  %# reverse order of odd columns
ind(ind==0) = [];                           %# keep non-zero indices

dct = D(ind(1:num_coeffs));                                     
end

