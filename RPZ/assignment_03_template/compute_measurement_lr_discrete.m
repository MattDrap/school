function x = compute_measurement_lr_discrete(imgs)
% Calculates difference between left and right half of image(s).
%   x = feature_lr_diff(imgs)
%
%   parameters:
%       imgs - 2 dimensional matrix or 3 dimensional matrix (set of images
%       or color image) or 4 dimensional matrix (set of color images)
%   
%   returns: values in range <-10, 10>
%
%   class support: integer classes

mu = -563.9;
sigma = 2001.6;

% size of the images
height = size(imgs, 1);
width = size(imgs, 2);
%count = size(imgs, 3);

% works even for matrix of color images (4 dimensions)
x_raw = squeeze( sum(sum(imgs(:,1:(width/2),:,:))) - sum(sum(imgs(:,(width/2+1):width,:,:))) );

x = round((x_raw - mu) / (2 * sigma) * 10);
x(x > 10) = 10;
x(x < -10) = -10;