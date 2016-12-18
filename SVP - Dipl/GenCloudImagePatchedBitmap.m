function [ output_img, output_cloud_mask, shadow_mask ] = GenCloudImagePatchedBitmap(img, metaballs, par)
%GENCLOUDIMAGEPATCHEDBITMAP Generates Cloud Image from cloudless image
%using metaballs
%img -- Cloudless image (Ground Truth)
%metaballs -- clouds approximated with metaballs
%with given structure [x_coord, y_coord, radius, densities, cloud_mask]
%par -- parametrization

[H,W,C] = size(img);
output_cloud_mask = zeros(H,W,C);
shadow_mask = zeros(H,W,C);

white = 255;

angle0 = 90 - par.sun_elevation;
angle0 = angle0 * pi / 180;

angle1 = 0; 
angle1 = angle1 * pi / 180;

for i = 1:size(metaballs, 1)
    radius = metaballs{i, 3};
    diameter = 2 * radius;

    cloud_bitmap = par.k2 * angle0 * metaballs{i, 5};
    %CLOUD
    ymin = floor(metaballs{i, 2} - radius);
    xmin = floor(metaballs{i, 1} - radius);
    
    xvec = xmin:xmin+ceil(diameter);
    yvec = ymin:ymin+ceil(diameter);
    
    clipX = xvec > size(img, 2) | xvec < 1;
    clipY = yvec > size(img, 1) | yvec < 1;
    
    xvec(clipX) = [];
    yvec(clipY) = [];
    %
    output_cloud_mask(yvec, xvec, :) = output_cloud_mask(yvec, xvec, :) + cloud_bitmap(~clipY, ~clipX, :);
    
    %SHADOW
    cloud_height = randi([15, 25], 1);
    x = tan(angle0)* cloud_height;
    dir = [cos(angle1); sin(angle1)];
    
    v = x*dir;
    
    shadow_x = metaballs{i, 1} + v(1);
    shadow_y = metaballs{i, 2} + v(2);
    %
    
    shadow_ymin = floor(shadow_y - radius);
    shadow_xmin = floor(shadow_x - radius);
    
    shadow_xvec = shadow_xmin:shadow_xmin+ceil(diameter);
    shadow_yvec = shadow_ymin:shadow_ymin+ceil(diameter);
    
    shadow_clipX = shadow_xvec > size(img, 2) | shadow_xvec < 1;
    shadow_clipY = shadow_yvec > size(img, 1) | shadow_yvec < 1;
    
    shadow_clipX = shadow_clipX | clipX;
    shadow_clipY = shadow_clipY | clipY;
    
    shadow_xvec(shadow_clipX) = [];
    shadow_yvec(shadow_clipY) = [];
    
    shadow_mask(shadow_yvec, shadow_xvec, :) = shadow_mask(shadow_yvec, shadow_xvec, :) ...
        + cloud_bitmap(~shadow_clipY, ~shadow_clipX, :) / 2;
end
    ww = white .* ones(H,W,C);
    shadow_mask = uint8(ww .* shadow_mask);
    output_cloud_mask = uint8(ww .* output_cloud_mask);
    output_img = output_cloud_mask + img - shadow_mask;
end

