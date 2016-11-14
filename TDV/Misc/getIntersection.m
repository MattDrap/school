function [intersection] = getIntersection(line_one, line_two, Bbox)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
originX = Bbox(1, 1);
originY = Bbox(2, 1);
width = Bbox(1, 2);
height = Bbox(2, 2);

cp = cross(line_one, line_two);

cp = p2e(cp);
if ( (cp(1) < originX) || (cp(1) > width) || (cp(2) < originY) || (cp(2) > height) )
    
    intersection = NaN;
    return;
end
intersection = cp;

end