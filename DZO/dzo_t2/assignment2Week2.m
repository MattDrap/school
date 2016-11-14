% path to the image to be carved
IMG_PATH = 'images/tower.jpg';
 
% path to the image defining which pixels should be deleted (drawn in blue
% color [0 0 255]) and protected from deletion (drawn in red [255 0 0]);
% replace with empty string to use no labeling of pixels
LABELING_PATH = 'images/tower_labeling.png';
 
% minimum number of seams to be carved out from the image;
% the actual number of seams takes the pixels to be deleted into account
NUM_SEAMS = 0;
 
% direction of carving: 'vertical' for columns and 'horizontal' for rows
DIRECTION = 'vertical';
 
% method for computing the vertex and edge costs: 'standard' is based on
% gradient estimation and 'forward' on difference of neighboring pixels
COST_METHOD = 'standard';
 
% load the input image
img = im2double(imread(IMG_PATH));
[h, w, ~] = size(img);
 
% load labeling of pixels to be deleted and protected and convert the
% labeling to two separate binary masks
mask_delete = false(h, w);
mask_protect = false(h, w);
if exist('LABELING_PATH', 'var') && exist(LABELING_PATH, 'file')
	labeling = load_pixel_labeling(LABELING_PATH, [255 0 0], [0 0 255]);
	mask_delete(labeling == 2) = true;
	mask_protect(labeling == 1) = true;
end
 
% show the input image
figure;
image(img);
axis image;
title('Input image');
 
% run the seam carving algorithm
[img_carved, seams] = seam_carving(img, DIRECTION, NUM_SEAMS, ...
    COST_METHOD, mask_delete, mask_protect);
 
% show the downsized image
figure;
image(img_carved);
axis image;
title('Downsized image');
 
% draw the constructed seams to the original image
img_seams = draw_seams(img, seams, DIRECTION);
 
% show the image with the marked seams
figure;
image(img_seams);
axis image;
title('Input image with marked seams');