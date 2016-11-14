function [x_t, y_t] = t_rot(x, y, angle)
% angle is in radians. 
%
% for each point with coordinates X, Y:  
% [X, Y] <-- R * [X, Y]
% where R is the rotation matrix: 
% R = [ C, S
%      -S  C]
% C = cos(angle) 
% S = sin(angle) 

% find centroid: 
xc = mean(x(:));
yc = mean(y(:));

x = (x - xc); 
y = (y - yc); 

C = cos(angle); 
S = sin(angle); 

x_t =  C*x + S*y + xc; 
y_t = -S*x + C*y + yc; 



