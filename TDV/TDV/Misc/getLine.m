function [linep1, linep2] = getLine(point_one, point_two, Bbox)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
originX = Bbox(1, 1);
originY = Bbox(2, 1);
width = Bbox(1, 2);
height = Bbox(2, 2);

l = cross(point_one, point_two);

l1 = cross([originX;originY;1], [width; originY; 1]);
l2 = cross([width;originY;1], [width; height; 1]);
l3 = cross([width; height; 1], [originX; height; 1]);
l4 = cross([originX; height; 1], [originX;originY;1]);

cp1 = cross(l, l1);
cp2 = cross(l, l2);
cp3 = cross(l, l3);
cp4 = cross(l, l4);

cp = [cp1, cp2, cp3, cp4];

cp = p2e(cp);

sig_e = 1e-5;
cp(:, cp(1, :) < originX | cp(1, :) > width + sig_e | cp(2, :) < originY | cp(2, :) > height + sig_e) = [];

if isempty(cp)
    linep1 = NaN;
    linep2 = NaN;
    return;
end
linep1 = cp(:, 1);
linep2 = cp(:, 2);

end