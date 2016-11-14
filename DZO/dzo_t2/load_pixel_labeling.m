function labeling = load_pixel_labeling(img_path, color_1, color_2, ...
	color_3, color_4)
% Load labeling of pixels from the given image. The optional arguments
% specify RGB colors of individual labels. The pixels having color 1 will
% be assigned label 1, pixels having color 2 will be assigned lanel 2 etc.

% default colors are red for label 1, blue for label 2, green for label 3
% and yellow for label 4
if ~exist('color_1', 'var')
	color_1 = [255 0 0];
end
if ~exist('color_2', 'var')
	color_2 = [0 0 255];
end
if ~exist('color_3', 'var')
	color_3 = [0 255 0];
end
if ~exist('color_4', 'var')
	color_4 = [255 255 0];
end

colors = [color_1; color_2; color_3; color_4];

img = imread(img_path);
[h, w, c] = size(img);
img = reshape(img, h * w, c);

labeling = zeros(h, w);
for i = 1:4
	ind_i = all(img == repmat(colors(i,:), h * w, 1), 2);
	labeling(ind_i) = i;
end

end
