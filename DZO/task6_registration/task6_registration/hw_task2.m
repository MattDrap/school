
im = double(imresize(imread('jay.jpg'), 0.2))/255; 

im_red = im(:,:,1); 
im_blue = im(:,:,3); 
im_target = 4*mod(im_blue, .25); 
% im_target = 1 - im_blue; 

xshift = 110; 
yshift = 40; 

template = im_target(yshift+1:yshift+80, xshift+1:xshift+84); 

offset = -10:10; 

val_mi = zeros(length(offset)); 
val_ssd = zeros(length(offset)); 

for ix = 1:length(offset)
    for iy = 1:length(offset)
        
        subimage = im_red(offset(iy)+(yshift+1:yshift+80), offset(ix)+(xshift+1:xshift+84));
        
        val_mi(iy, ix) = mutual_information(template, subimage); 
        val_ssd(iy, ix) = sum_of_squares(template, subimage); 
    end
end

figure; 
[x, y] = meshgrid(offset, offset); 
surf(x, y, val_ssd); axis equal; colormap jet; ...
    view(2); colorbar; title('SSD'); 
xlabel('x offset'); ylabel('y offset')

figure; surf(x, y, val_mi); axis equal; colormap jet; view(2); ...
    colorbar; title('MI')
xlabel('x offset'); ylabel('y offset')




