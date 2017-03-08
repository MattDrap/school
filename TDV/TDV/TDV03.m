clear all;
close all;
clc;
addpath('../Misc');

extents = [1, 800;
           1, 600];
extent_points = [1, 1, 800, 800;
                 1, 600, 600, 1];
              
f = figure;
hold on;
plot(extent_points(1, :), extent_points(2, :), 'k');
plot([extent_points(1, end), extent_points(1, 1)], [extent_points(2, end), extent_points(2, 1)], 'k');
set(gca, 'XLim', [-10, 810]);
set(gca, 'YLim', [-10, 610]);

[u, v] = ginput(2);

x = [u';v'];
x = e2p(x);
[p1, p2] = getLine(x(:, 1), x(:, 2), extents);
if ~isempty(p1)
    plot([p1(1), p2(1)], [p1(2), p2(2)], 'b');
end
line = p2 - p1;
line = line / norm(line);
sigx = 3;

t = linspace(1, 800, 800);
onlinepoints = repmat(p1, 1 , 800) + [t;t].* repmat(line, 1, 800) + normrnd(zeros(2, 800), sigx);

px = rand(200, 1) * (extents(1, 2) - 1) + extents(1, 1);
py = rand(200, 1) * (extents(2, 2) - 1) + extents(2, 1);
outlying_points = [px'; py'];

points = [onlinepoints, outlying_points ];
scatter(points(1, :), points(2, :), 2.5, 'ok', 'filled');
points = e2p(points);
[l, val] = fminsearch(@(n) Optimization(n, points), [rand(1); rand(1); rand(1)]);
[ll, inl] = ransac(points, 3, 0.95);
inl_points = points(:, inl);
[l2, val2] = fminsearch(@(n) Optimization(n, inl_points), ll);
l2 = e2p(p2e(l2));
%%
[minp1, minp2] = getLineLine(l, extents);
[minp3, minp4] = getLineLine(ll, extents);
[minp5, minp6] = getLineLine(l2, extents);
if ~isnan(minp1)
    plot([minp1(1), minp2(1)], [minp1(2), minp2(2)], 'g');
end
if ~isnan(minp3)
    plot([minp3(1), minp4(1)], [minp3(2), minp4(2)], 'r');
end
if ~isnan(minp5)
    plot([minp5(1), minp6(1)], [minp5(2), minp6(2)], 'c');
end