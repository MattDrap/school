function segmentation_gui(img_path)

hfig = figure;
set(hfig, ...
	'Units', 'normalized', ...
	'name', sprintf('Image file: %s', img_path), ...
	'WindowButtonDownFcn', @mouse_down, ...
	'WindowButtonMotionFcn', @mouse_move, ...
	'WindowButtonUpFcn', @mouse_up);

img = im2double(imread(img_path));
[img_h, img_w, img_c] = size(img);

% check whether the image is grayscale and force it having 3 channels
if img_c == 1
	img = repmat(img, [1 1 3]);
	img_grayscale = true;
else
	pix_diff = diff(reshape(img, [img_h * img_w, img_c])');
	img_grayscale = all(pix_diff(:) == 0);
end

create_ui_control('text', [1 0 0.4], 'Tool:');
htool = create_ui_control('popupmenu', [1 0.4 0.6], ...
	{'Brush', 'Rectangle'}, @clear_annotation);

% use different algorithms for grayscale and RGB images
create_ui_control('text', [2 0 0.4], 'Algorithm:');
if img_grayscale
	alg = {'Histogram'};
else
	alg = {'GMM', 'Graphcut', 'GrabCut'};
end
halg = create_ui_control('popupmenu', [2 0.4 0.6], alg);

create_ui_control('pushbutton', 3, 'Clear', @clear_annotation);

create_ui_control('pushbutton', 4, 'Segment', @segment);

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
setappdata(hfig, 'img_size', [img_h img_w]);
setappdata(hfig, 'polyline_left', {});
setappdata(hfig, 'polyline_right', {});
setappdata(hfig, 'hrect', []);
setappdata(hfig, 'haxes', haxes);
setappdata(hfig, 'htool', htool);
setappdata(hfig, 'halg', halg);
setappdata(hfig, 'mouse_action', 'none');
setappdata(hfig, 'brush_size', 8);

end


function clear_annotation(hobj, ~)

hfig = ancestor(hobj, 'figure');
polyline_left = getappdata(hfig, 'polyline_left');
polyline_right = getappdata(hfig, 'polyline_right');
hrect = getappdata(hfig, 'hrect');

for i = 1:numel(polyline_left)
	delete(polyline_left{i});
end

for i = 1:numel(polyline_right)
	delete(polyline_right{i});
end

if ~isempty(hrect)
	delete(hrect);
end

setappdata(hfig, 'polyline_left', {});
setappdata(hfig, 'polyline_right', {});
setappdata(hfig, 'hrect', []);

drawnow();

end


function segment(hobj, ~)

hfig = ancestor(hobj, 'figure');
img = getappdata(hfig, 'img');
img_size = getappdata(hfig, 'img_size');
htool = getappdata(hfig, 'htool');
halg = getappdata(hfig, 'halg');

% build initial labeling mask
mask = zeros(img_size);
tool_str = get(htool, 'String');
tool = tool_str{get(htool, 'Value')};
if strcmpi('Brush', tool)
	mask_left = polyline_to_mask(hfig, 'polyline_left');
	mask_right = polyline_to_mask(hfig, 'polyline_right');
	mask(mask_left == 1) = 1;
	mask(mask_right == 1) = 2;
elseif strcmpi('Rectangle', tool)
	mask_rect = rectangle_to_mask(hfig);
	mask(mask_rect == 0) = 2;
	mask(mask_rect == 1) = 3;
end

figure;
imshow(compose_labeled_image(img, mask));
title('Initial labeling')

% segmentation parameters for all methods
HIST_NUM_BINS = 256;
HIST_SIGMA = 3;
NUM_COMPS = 3;
KMEANS_ITER = 100;
NEIGHBORHOOD_TYPE = 8;
LAMBDA_1 = 5;
LAMBDA_2 = 45;
GRAPHCUT_ITER = 3;

% perform segmentation
algorithm_str = get(halg, 'String');
algorithm = algorithm_str{get(halg, 'Value')};
switch algorithm
	case 'Histogram'
		seg = segmentation_hist(img(:,:,1), mask, HIST_NUM_BINS, ...
			HIST_SIGMA);
	case 'GMM'
		seg = segmentation_gmm(img, mask, NUM_COMPS, KMEANS_ITER);
	case 'Graphcut'
		seg = segmentation_graphcut(img, mask, NUM_COMPS, KMEANS_ITER, ...
			NEIGHBORHOOD_TYPE, LAMBDA_1, LAMBDA_2);
	case 'GrabCut'
		seg = segmentation_grabcut(img, mask, NUM_COMPS, KMEANS_ITER, ...
			NEIGHBORHOOD_TYPE, LAMBDA_1, LAMBDA_2, GRAPHCUT_ITER);
end

figure;
imshow(compose_labeled_image(img, seg));
title('Final segmentation')

end


function mouse_down(hobj, ~)

hfig = ancestor(hobj, 'figure');
htool = getappdata(hfig, 'htool');

p = get_figure_point(hfig);
if ~isempty(p)
    tool_str = get(htool, 'String');
    tool = tool_str{get(htool, 'Value')};
	if strcmpi('Brush', tool)
		selection_type = get(hfig, 'SelectionType');
		if strcmpi('normal', selection_type)
			setappdata(hfig, 'mouse_action', 'left');
		else
			setappdata(hfig, 'mouse_action', 'right');
		end
		update_figure_polyline(hfig, p, true);
	elseif strcmpi('Rectangle', tool)
		setappdata(hfig, 'mouse_action', 'rect');
		update_figure_rectangle(hfig, p, true);
	end
end

end


function mouse_move(hobj, ~)

hfig = ancestor(hobj, 'figure');
mouse_action = getappdata(hfig, 'mouse_action');

if ~strcmpi('none', mouse_action)
	p = get_figure_point(hfig);
	if ~isempty(p)
		if strcmpi('rect', mouse_action)
			update_figure_rectangle(hfig, p, false);
		else
			update_figure_polyline(hfig, p, false);
		end
	end
end

end


function mouse_up(hobj, ~)

hfig = ancestor(hobj, 'figure');
setappdata(hfig, 'mouse_action', 'none');

end


function mask = polyline_to_mask(hfig, polyline_name)

img_size = getappdata(hfig, 'img_size');
polyline = getappdata(hfig, polyline_name);
brush_size = getappdata(hfig, 'brush_size');

mask = zeros(img_size);

for i = 1:numel(polyline)
	% get points of one line
	hline = polyline{i};
	pts = [get(hline, 'YData'); get(hline, 'XData')];
	
	% compute length of segments to be added between points
	dists = pts(:,2:end) - pts(:,1:end-1);
	dists = sqrt(sum(dists.^2, 1));
	seg_lengths = floor(dists) + 1;
	
	% build dense line points
	pts_dense = pts(:,1);
	for j = 1:size(dists, 2)
		if seg_lengths(j) >= 3
			% subsequent points are distant -> interpolate
			seg_x = linspace(pts(1,j), pts(1,j+1), seg_lengths(j));
			seg_y = linspace(pts(2,j), pts(2,j+1), seg_lengths(j));
			pts_dense = cat(2, pts_dense, round([seg_x(2:end); seg_y(2:end)]));
		elseif seg_lengths(j) >= 2
			% subsequent points are close, but not identical
			pts_dense = cat(2, pts_dense, pts(:,j+1));
		end
	end
	
	% convert points to indices and write them to binary mask
	line_ind = sub2ind(img_size, pts_dense(1,:), pts_dense(2,:));
	mask(line_ind) = 1;
end

% dilate the mask to emulate a thick brush
mask = imdilate(mask, ones(brush_size));

end


function mask = rectangle_to_mask(hfig)

img_size = getappdata(hfig, 'img_size');
hrect = getappdata(hfig, 'hrect');

mask = zeros(img_size);

if ~isempty(hrect)
	r = get(hrect, 'Position');
	mask = roipoly(mask, ...
		[r(1), r(1), r(1) + r(3), r(1) + r(3)], ...
		[r(2), r(2) + r(4), r(2) + r(4), r(2)]);
end

end


function p = get_figure_point(hfig)

haxes = getappdata(hfig, 'haxes');
img_size = getappdata(hfig, 'img_size');

p = get(haxes, 'CurrentPoint');
p = round(p(1,1:2));

if p(1) < 1 || p(2) < 1 || img_size(2) < p(1) || img_size(1) < p(2)
	p = [];
end

end


function update_figure_polyline(hfig, p, begin_line)

mouse_action = getappdata(hfig, 'mouse_action');
brush_size = getappdata(hfig, 'brush_size');

if strcmpi('left', mouse_action)
	polyline_name = 'polyline_left';
	line_color = [1 0 0];
elseif strcmpi('right', mouse_action)
	polyline_name = 'polyline_right';
	line_color = [0 0 1];
end

polyline = getappdata(hfig, polyline_name);

if begin_line
	hline = line(p(1), p(2), 'Color', line_color, 'LineWidth', brush_size);
	polyline = [polyline, {hline}];
else
	hline = polyline{end};
	line_x = [get(hline, 'XData'), p(1)];
	line_y = [get(hline, 'YData'), p(2)];
	set(hline, 'XData', line_x, 'YData', line_y);
end

setappdata(hfig, polyline_name, polyline);

end


function update_figure_rectangle(hfig, p, begin_rectangle)

hrect = getappdata(hfig, 'hrect');

if begin_rectangle
	if ~isempty(hrect)
		delete(hrect);
	end
	hrect = rectangle('Position', [p(1) p(2) 1 1], 'EdgeColor', [0 1 0]);
else
	r = get(hrect, 'Position');
	w = max(p(1) - r(1), 1);
	h = max(p(2) - r(2), 1);
	set(hrect, 'Position', [r(1), r(2), w, h]);
end

setappdata(hfig, 'hrect', hrect);

end


function control = create_ui_control(style, pos, text, callback)

% width, height and margin of one control element
ELEM_WIDTH = 0.25;
ELEM_HEIGHT = 0.06;
ELEM_MARGIN = 0.01;

if numel(pos) == 1
	pos = [0, 1 - pos * ELEM_HEIGHT, ...
        ELEM_WIDTH - ELEM_MARGIN, ELEM_HEIGHT - ELEM_MARGIN];
else
	pos = [pos(2) * ELEM_WIDTH, 1 - pos(1) * ELEM_HEIGHT, ...
        pos(3) * ELEM_WIDTH - ELEM_MARGIN, ELEM_HEIGHT - ELEM_MARGIN];
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
