function patch = getPatchSubpix(img,x,y,win_x,win_y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[H,W] = size(img);
ldx = floor(x-win_x);
ldx(ldx < 1) = 1;
ldx(ldx > W) = W;
hdx = ceil(x+win_x);
hdx(hdx > W) = W;
hdx(hdx < 1) = 1;

ldy = floor(y-win_y);
ldy(ldy < 1) = 1;
ldy(ldy > H) = H;
hdy = ceil(y+win_y);
hdy(hdy > H) = H;
hdy(hdy < 1) = 1;

cropped = img(ldy:hdy, ldx:hdx);
if size(cropped, 1) <= 1 || size(cropped, 2) <= 1
    patch = NaN;
    return;
end
nx = x-ldx+1;
ny = y-ldy+1;

[mx, my] = meshgrid(linspace(nx-win_x,nx+win_x, 2*win_x+1), linspace(ny-win_y,ny+win_y, 2*win_y+1)); 
patch = interp2(double(cropped), mx, my);
patch(isnan(patch)) = 0;
end

