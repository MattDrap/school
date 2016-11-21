function [ output_img, output_cloud_mask ] = GenCloudImagePatched(img, metaballs, par)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[H,W,~] = size(img);
output_img = img;
output_cloud_mask = zeros(H,W);
for i = 1:size(metaballs, 1)
    i
    radius = metaballs(i, 3);
    diameter = 2 * radius;

    ymin = floor(metaballs(i, 2) - radius);
    xmin = floor(metaballs(i, 1) - radius);
    
    subimg = imcrop(img, [xmin, ymin, diameter, diameter]);
    
    tempmetaballs = metaballs;
    tempmetaballs(:, 1) = tempmetaballs(:, 1) - metaballs(i, 1) + radius;
    tempmetaballs(:, 2) = tempmetaballs(:, 2) - metaballs(i, 2) + radius;
    
    [CImage, cloud_mask] = GenCloudImage(subimg, tempmetaballs, par);
    
    xvec = xmin:xmin+ceil(diameter);
    yvec = ymin:ymin+ceil(diameter);
    
    xvec(xvec > size(img, 2)) = [];
    yvec(yvec > size(img, 1)) = [];
    xvec(xvec < 1) = [];
    yvec(yvec < 1) = [];
    
    output_img(yvec, xvec) = CImage;
    output_cloud_mask(yvec, xvec) = cloud_mask;
end
end

