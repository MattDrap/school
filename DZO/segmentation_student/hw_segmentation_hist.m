close all;
clear;

% parameters
NUM_BINS = 256;
SIGMA = 3;

% load grayscale image and its labeling
img = rgb2gray(im2double(imread('images/zebra.jpg')));
lab_in = load_pixel_labeling('images/zebra_brush.png');

figure();
imshow(compose_labeled_image(img, lab_in));
title('Image and its initial labeling');

% construct PDFs for sample input foreground and background pixels
gray_fore = img(lab_in == 1);
hist_fore = hist_pdf(gray_fore, NUM_BINS, SIGMA);
gray_back = img(lab_in == 2);
hist_back = hist_pdf(gray_back, NUM_BINS, SIGMA);

figure();
hold on;
plot(linspace(0, 1, NUM_BINS), hist_fore, 'r');
plot(linspace(0, 1, NUM_BINS), hist_back, 'b');
legend('Foreground', 'Background');
title('PDFs based on histograms');

% run segmentation
lab_seg = segmentation_hist(img, lab_in, NUM_BINS, SIGMA);

figure();
imshow(compose_labeled_image(img, lab_seg));
title('Image and the final segmentation');
