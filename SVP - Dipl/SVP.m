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
    
    density = rand() / 3;
    metaballs(i, 4) = density;
end

%%
nimg = img;
white = [1, 1, 1]';

m = repmat(metaballs(:, 1:2)', 1, 1, W);
metaballsRs = repmat(metaballs(:, 3), 1, W);
densities = repmat(metaballs(:, 4), 1, W);
WWhite = repmat(white, 1, W);

for i = 1:H
    coord = permute( repmat([1:W; repmat(i, 1, W)], [1, 1, num_of_metaballs] ), [1, 3, 2] );
    
    Wdists = squeeze(sqrt(sum( (coord - m) .^2)));
     
   % F = compute_f(Wdists, metaballs, W);
    
    lookup = Wdists <= metaballsRs;

    F = -4/9.*(Wdists./ metaballsRs).^6 + 17/9*(Wdists ./ metaballsRs).^4 ...
        - 22/9*(Wdists ./ metaballsRs).^2 + 1;
    F(~lookup) = 0;
    F = F .* densities;
    F = sum(F);
    
    C = repmat(F, 3, 1) .* WWhite;
    D = repmat(1-F, 3, 1) .* squeeze(img(i, 1:W, :))';
    CC = C + D ./ WWhite;
    nimg(i, 1:W, :) = CC';
    
    if mod(i, 100) == 0
        sprintf('%d / %d', i, H)
    end
end
subplot(1, 2, 1);
imshow(img);
subplot(1, 2, 2);
imshow(nimg);
