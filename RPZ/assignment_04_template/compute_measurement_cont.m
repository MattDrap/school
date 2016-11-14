function features = compute_measurement_cont(imgs)
% x = compute_measurement_cont(imgs)
%
%   Compute measurement on images, subtract sum of right half from sum of
%   left half and bottom from top
%
%   Parameters:
%       imgs - set of images, <h x w x n>
%
%   Return:
%       x - measurements, <2 x n>

width = size(imgs(:,:,1), 2);
height = size(imgs(:,:,1), 1);
sumRows = sum(double(imgs));
sumCols = sum(double(imgs),2);

x = sum(sumRows(1,1:(width/2),:)) - sum(sumRows(1,(width/2+1):width,:));
y = sum(sumCols(1:(height/2),1,:)) - sum(sumCols((height/2+1):height,1,:));
x = reshape(x,1,size(imgs,3));
y = reshape(y,1,size(imgs,3));
features = [x;y];
