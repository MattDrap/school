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

[u, v] = ginput(4);
%%
plot(u, v, 'o');
x = [u';v'];
x = e2p(x);
[p1, p2] = getLine(x(:, 1), x(:, 2), extents);
if ~isempty(p1)
    plot([p1(1), p2(1)], [p1(2), p2(2)], 'b');
end
[p3, p4] = getLine(x(:, 3), x(:, 4), extents);
if ~isempty(p3)
    plot([p3(1), p4(1)], [p3(2), p4(2)], 'g');
end

line1 = cross(x(:, 1), x(:, 2));
line2 = cross(x(:, 3), x(:, 4));

[sect] = getIntersection(line1, line2, extents);
if ~isempty(sect)
    plot(sect(1), sect(2) , 'ro');
end


hold off;
%%
H = [1     0.1   0;
     0.1   1     0;
     0.004 0.002 1 ];
figure;
hold on;
extent_points2 = p2e(H*e2p(extent_points));
plot(extent_points2(1, :), extent_points2(2, :), 'k');
plot([extent_points2(1, end), extent_points2(1, 1)], [extent_points2(2, end), extent_points2(2, 1)], 'k');

points_p = p2e(H*e2p([u';v']));
plot(points_p(1,:), points_p(2, :), 'o');

p1_p = p2e(H*e2p(p1));
p2_p = p2e(H*e2p(p2));
plot([p1_p(1), p2_p(1)], [p1_p(2), p2_p(2)], 'b');
p3_p = p2e(H*e2p(p3));
p4_p = p2e(H*e2p(p4));
plot([p3_p(1), p4_p(1)], [p3_p(2), p4_p(2)], 'g');
sect_p = p2e(H*e2p(sect));
plot(sect_p(1), sect_p(2) , 'ro');
hold off;