function lab = load_pixel_labeling(img_path)
% Load labeling of pixels from the given image. Red pixels will be assigned
% label 1, blue pixels labels 2, green 3, yellow 4, cyan 5, magenta 6.

img = im2double(imread(img_path));
[h, w, c] = size(img);
rgb = reshape(img, h * w, c);

colors = get_label_colors();
num_colors = size(colors, 1);

lab = zeros(h, w);
for i = 1:num_colors
	idx_i = all(rgb == repmat(colors(i,:), h * w, 1), 2);
	lab(idx_i) = i;
end

end
