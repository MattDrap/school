function S = sqc(x)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
S = cross(repmat(x, 1, 3), eye(3,3));

end

