function [] = drawLine(l, color, width, height)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
l1 = cross([0;0;1], [width; 0; 1]);
l2 = cross([width;0;1], [width; height; 1]);
l3 = cross([width; height; 1], [0; height; 1]);
l4 = cross([0; height; 1], [0;0;1]);

cp1 = cross(l, l1);
cp2 = cross(l, l2);
cp3 = cross(l, l3);
cp4 = cross(l, l4);

cp = [cp1, cp2, cp3, cp4];

cp = bsxfun(@rdivide, cp, cp(3, :));

cp(:, cp(1, :) < 0 | cp(1, :) > width+1 | cp(2, :) < 0 | cp(2) > height + 1) = [];

plot([cp(1, 1), cp(1, 2)], [cp(2, 1), cp(2, 2)], 'Color', color);
end