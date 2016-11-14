function [x,y]=harris(img,sigmad,sigmai,thresh)
%harris harris corner detector
%   Detailed explanation goes here
H = harris_response(img, sigmad, sigmai);
S = nonmaxsup2d(H, thresh);

[y, x] = find(S);
y = y'-1;
x = x'-1;

end

