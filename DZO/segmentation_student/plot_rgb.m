function h = plot_rgb(rgb, max_values, color)
% Plot maximally specified number of RGB values as points in [0,1]^3 cube.
% The points are colored according to their value.

num_rgb = size(rgb, 2);

% if maximal number of values it not specified then plot them all
if ~exist('max_values', 'var')
	max_values = num_rgb;
end

% ensure that not too many points are plot
if num_rgb > max_values
    ind = randperm(num_rgb, max_values);
    rgb = rgb(:,ind);
end

% if color is not specified then use the RGB values themselves
if ~exist('color', 'var')
    color = rgb';
end

h = scatter3(rgb(1,:), rgb(2,:), rgb(3,:), 10, color, 'filled');

axis equal;
grid on;
xlabel('red');
ylabel('green');
zlabel('blue');
view(40, 35);

end
