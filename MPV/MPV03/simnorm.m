function pts=simnorm(img,x,y,s,opt)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    pts=affnorm(img,x,y,s,zeros(1, length(x)),zeros(1, length(x)),s,opt);

end

