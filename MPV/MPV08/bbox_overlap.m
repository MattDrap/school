function [p] = bbox_overlap(bb1, bb2);
%
% [p] = bbox_overlap(bb1, bb2);
%
%  p - overlap (ratio); intersection over union
%  
%   bb1, bb2 (4x1) [top_left_col top_left_row bottom_right_col bottom_right_row]
%

if (numel(bb1)~=4) || (numel(bb2)~=4)
	error('Invalid bounding box format.')
end

if size(bb1,1)>size(bb1,2)
	bb1 = bb1'; 
end

if size(bb2,1)>size(bb2,2)
	bb2 = bb2'; 
end


x1 = max(bb1(1), bb2(1)); %inner box
x2 = min(bb1(3), bb2(3));
y1 = max(bb1(2), bb2(2));
y2 = min(bb1(4), bb2(4));

X = [bb1([1,3]),bb2([1,3])];
Y = [bb1([2,4]),bb2([2,4])];
ob = [min(X), min(Y), max(X), max(Y)]; %outer box

if (x1 <= x2) && (y1 <= y2)
    p = ( (x2-x1)*(y2-y1) ) / ( (ob(3)-ob(1))*(ob(4)-ob(2)) );
else
    p = 0;
end
