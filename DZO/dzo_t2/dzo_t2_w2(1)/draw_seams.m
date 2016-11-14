function img_seams = draw_seams(img, seams, direction)
% Compose image showing the specified original image and the list of seams
% which have been carved out. The seams are drawn directly to the image.
% The direction of seams can be from {'vertical','horizontal'}.

SEAM_COLOR = [1 0 0];

direction_vertical = strcmpi(direction, 'vertical');

[h, w, ~] = size(img);
num_seams = size(seams, 2);

% add offset to all seams
for i = num_seams:-1:2
	for j = (i-1):-1:1
		seams(:,i) = seams(:,i) + (seams(:,i) >= seams(:,j));
	end
end

% build image showing all carved seams
img_seams = img;
for i = 1:num_seams
    if direction_vertical
		seam_ind = sub2ind([h w], 1:h, seams(:,i)');
	else
		seam_ind = sub2ind([h w], seams(:,i)', 1:w);
    end
    img_seams = draw_pixels(img_seams, seam_ind, SEAM_COLOR);
end

end
