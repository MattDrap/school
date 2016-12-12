function [ Cropped, new_center ] = CropSat( Im, center, radius, crop_edge)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if ~exist('crop_edge', 'var')
    crop_edge = false;
end

diameter = 2 * radius;

ymin = floor(center(1) - radius);
xmin = floor(center(2) - radius);

y = ymin:ymin+diameter;
x = xmin:xmin+diameter;

[H, W, C] = size(Im);

txl = x < 1;
tyl = y < 1;
txm = x > W;
tym = y > H;

tx = txl | txm;
ty = tyl | tym;

x(tx) = [];
y(ty) = [];

if crop_edge
Cropped = Im(y, x, :);
else
Cropped = uint8(zeros(diameter + 1, diameter + 1, C));
yl = find(tyl == 0, 1);
yh = find(tym == 0, 1, 'last');
xl = find(txl == 0, 1);
xh = find(txm == 0, 1, 'last');
Cropped(yl:yh, xl:xh, :) = Im(y, x, :);
end

new_center = ceil(size(Cropped) / 2);
new_center = new_center(1:2);
end

