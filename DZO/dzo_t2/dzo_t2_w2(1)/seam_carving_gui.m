function seam_carving_gui(img_path)

hfig = figure;
set(hfig, ...
	'Units', 'normalized', ...
	'name', sprintf('Image file: %s', img_path));

img = double(imread(img_path)) / 255;
[img_h, img_w, ~] = size(img);

% protection and deletion masks are empty at the beginning
mask_delete = false(img_h, img_w);
mask_protect = false(img_h, img_w);

create_ui_control('pushbutton', 1, 'Define delete', ...
	{@define_mask, 'mask_delete'});

create_ui_control('pushbutton', 2, 'Clear delete', ...
	{@clear_mask, 'mask_delete'});

create_ui_control('pushbutton', 3, 'Define protected', ...
	{@define_mask, 'mask_protect'});

create_ui_control('pushbutton', 4, 'Clear protected', ...
	{@clear_mask, 'mask_protect'});

create_ui_control('text', [5 0 0.4], 'Cost:');
hcost = create_ui_control('popupmenu', [5 0.4 0.6], ...
	{'Standard', 'Forward'});

create_ui_control('text', [6 0 0.4], 'Direction:');
hdir = create_ui_control('popupmenu', [6 0.4 0.6], ...
	{'Vertical', 'Horizontal'});

create_ui_control('text', [7 0 0.4], 'Seams:');
hseams = create_ui_control('edit', [7 0.4 0.6], 0);

create_ui_control('pushbutton', 8, 'Carve', @carve);

haxes = axes(...
	'Units', 'normalized', ...
	'Box', 'on', ...
	'XGrid', 'off', 'YGrid', 'off', ...
	'Xlim', [1 img_w], 'Ylim', [1 img_h], ...
	'NextPlot', 'add', ...
	'interruptible', 'off', ...
	'YDir', 'reverse', ...
	'xlimmode', 'manual', 'ylimmode', 'manual', 'zlimmode', 'manual', ...
	'DataAspectratio', [1 1 1], ...
	'xtick', [], 'ytick', [], ...
	'Position', [0.25 0 0.74 1]);
imagesc(img, 'parent', haxes);

setappdata(hfig, 'img', img);
setappdata(hfig, 'mask_protect', mask_protect);
setappdata(hfig, 'mask_delete', mask_delete);
setappdata(hfig, 'haxes', haxes);
setappdata(hfig, 'hcost', hcost);
setappdata(hfig, 'hdir', hdir);
setappdata(hfig, 'hseams', hseams);

end


function define_mask(hobj, ~, mask_name)

hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');
haxes = getappdata(hfig, 'haxes');

% let the user to specify coordinates of the bounding polygon
[x, y] = getline(haxes);

% convert the polygon to binary mask
mask = roipoly(img, x, y);
mask = logical(mask);

setappdata(hfig, mask_name, mask);
redraw_image(hfig);

end


function clear_mask(hobj, ~, mask_name)

hfig = ancestor(hobj, 'figure');
mask = getappdata(hfig, mask_name);

% clear the mask
mask = false(size(mask));

setappdata(hfig, mask_name, mask);
redraw_image(hfig);

end


function carve(hobj, ~)

hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');

% mask defined by the user
mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');

% properties of the method
hcost = getappdata(hfig, 'hcost');
cost_method = hcost.String{hcost.Value};
hdir = getappdata(hfig, 'hdir');
direction = hdir.String{hdir.Value};
hseams = getappdata(hfig, 'hseams');
num_seams = str2double(hseams.String);

% carve seams from the image
[img_carve, seams] = seam_carving(img, direction, num_seams, ...
	cost_method, mask_delete, mask_protect);

figure;
imagesc(img_carve);
axis image off;
title('Carved image');

% visualize carved seams
img_seams = draw_seams(img, seams, direction);

figure;
imagesc(img_seams);
axis image off;
title('Seams projected to the original image');

end


function redraw_image(hfig)

img = getappdata(hfig, 'img');
mask_delete = getappdata(hfig, 'mask_delete');
mask_protect = getappdata(hfig, 'mask_protect');
haxes = getappdata(hfig, 'haxes');

% draw both masks to the image
img = draw_mask(img, mask_delete, [255 0 0], 0.5);
img = draw_mask(img, mask_protect, [0 255 0], 0.5);

% show the modified image
imagesc(img, 'parent', haxes);

end


function control = create_ui_control(style, pos, text, callback)

% width and height of control element
CW = 0.25;
CH = 0.06;
MARG = 0.01;

if numel(pos) == 1
	pos = [0, 1 - pos * CH, CW - MARG, CH - MARG];
else
	pos = [pos(2) * CW, 1 - pos(1) * CH, pos(3) * CW - MARG, CH - MARG];
end

if ~exist('callback', 'var')
	callback = '';
end

control = uicontrol(...
	'Style', style, ...
	'Units', 'Normalized', ...
	'Position', pos, ...
	'String', text, ...
	'Callback', callback);

end


function mask_img = draw_mask(img, mask, color, alpha)

[h, w, c] = size(img);
mask_img = img;
for i = 1:c
	ind_i = find(mask) + (i - 1) * h * w;
	mask_img(ind_i) = alpha * mask_img(ind_i) + (1 - alpha) * color(i);
end

end
