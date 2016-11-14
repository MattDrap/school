img = imread('img.jpg');
num_of_metaballs = 500;
metaballs = zeros(num_of_metaballs, 4);

img = im2double(img);
img = imresize(img, 0.25);
[H, W, C] = size(img);

for i = 1:num_of_metaballs
    radius = rand * 20 + 1;
    metaballs(i, 3) = radius;
    
    centerX = W * rand + 1;
    centerY = H * rand + 1;
    
    metaballs(i, 1) = centerX;
    metaballs(i, 2) = centerY;
    
    density = rand();
    metaballs(i, 4) = density;
end

%%
nimg = img;
white = [1, 1, 1]';
k2 = 0.9;
angle0 = 30;
angle0 = angle0 * pi / 180;
cloud_mask = zeros(H,W);
for i = 1:H
    for j=1:W
        dists = sqrt(sum((repmat([j, i], num_of_metaballs, 1) - metaballs(:, 1:2)).^2, 2));
        lookup = dists <= metaballs(:, 3);
        ballsR = metaballs(:, 3);
        f = -4/9.*(dists ./ ballsR).^6 + 17/9*(dists ./ ballsR).^4 ...
           - 22/9*(dists ./ ballsR).^2 + 1;

        f(~lookup) = 0;
       
       cloud_mask(i,j) = k2 * angle0 * sum(metaballs(:, 4) .* f);
        if ~isempty(f)
           nimg(i, j, :) =  (cloud_mask(i, j) * white + squeeze(img(i, j, :)));
       end
    end
    if mod(i, 100) == 0
        sprintf('%d / %d', i, H)
    end
end
subplot(1, 2, 1);
imshow(img);
subplot(1, 2, 2);
imshow(nimg);


angle1 = 90; 
angle1 = angle1 * pi / 180;
metaShadow = metaballs;
for i = 1:num_of_metaballs
    x = tan(angle0)*300
    dir = [cos(angle1); sin(angle1)];
    
    v = x*dir;
    
    metaShadow(i, 1:2) = metaShadow(i, 1:2) + v';
end
%%
nimg2 = img;
shadow_mask = zeros(H,W);
ks2 = 0.3;
for i = 1:H
    for j=1:W
        dists = sqrt(sum((repmat([j, i], num_of_metaballs, 1) - [metaShadow(:, 1:2)]).^2, 2));
        lookup = dists <= metaShadow(:, 3);
        ballsR = metaShadow(lookup, 3);
        f = -4/9.*(dists(lookup) ./ ballsR).^6 + 17/9*(dists(lookup) ./ ballsR).^4 ...
           - 22/9*(dists(lookup) ./ ballsR).^2 + 1;
       
       shadow_mask(i,j) = ks2 * angle0 * sum(metaShadow(lookup, 4) .* f);
       nimg2(i, j, :) = -(shadow_mask(i,j) * white) + squeeze(nimg2(i, j, :));
       nimg2(i, j, :) =  cloud_mask(i,j) * white + squeeze(nimg2(i, j, :));
    end
    if mod(i, 100) == 0
        sprintf('%d / %d', i, H)
    end
end
subplot(1, 2, 1);
imshow(img);
subplot(1, 2, 2);
imshow(nimg2);