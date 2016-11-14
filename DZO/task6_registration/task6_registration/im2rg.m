function im = im2rg(im1, im2)
sz = size(im1); 

im = zeros([sz(1), sz(2), 3]); 
im(:,:,1) = im1; 
im(:,:,2) = im2; 
im(im<0) =0; 
im(im>1) = 1; 
