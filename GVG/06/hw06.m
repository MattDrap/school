num_ims = 7;
%%
images = cell(1, num_ims);
for i = 1:num_ims
    images{i} = imread(sprintf('bridge_0%d.jpg', i));
end
%%
u = cell(num_ims, num_ims);
if ~exist('06_data.mat')
    for i = num_ims:-1:2
        mu = edit_points({images{i}, images{i-1}}, [], []);
        u{i, i-1} = mu{1};
        u{i-1, i} = mu{2};
        save('06_data.mat','u');
    end
else
    load('06_data.mat');
end
H = cell(num_ims, num_ims);
PSel = cell(1, num_ims);
Merr = cell(1, num_ims);
for i = num_ims:-1:2
    [Hbest, point_sel, max_error ] = u2h_optim(u{i, i-1}, u{i-1, i});
    H{i, i-1} = Hbest;
    PSel{i} = point_sel;
    Merr{i} = max_error;
end

%%
fig = figure;
hold on;
Histdist = [];
for i = num_ims:-1:2
    x = u{i, i-1};
    mH = H{i, i-1};
    proj = mH*[x; ones(1, size(x, 2))];
    proj(1, :) = proj(1, :)./proj(3, :);
    proj(2, :) = proj(2, :)./proj(3, :);
    
    y = u{i-1, i};
    dists = sqrt(sum((y-proj(1:2, :)).^2));
    d = hist(dists, 0:10);
    Histdist = [Histdist; d];
end
bar(0:10, Histdist');
legend('76', '65', '54', '43', '32', '21');
xlim([0 10]);
xlabel('err [px]');
ylabel('count');
fig2pdf(fig, '06_histograms.pdf');
%%
H{4,4} = eye(3,3);
H{3,4} = inv(H{4, 3});
H{2,4} = H{3, 4} * inv(H{3, 2});
H{1,4} = H{2, 4} * inv(H{2, 1});

H{5,4} = H{5, 4};
H{6,4} = H{5, 4} * H{6, 5};
H{7,4} = H{6, 4} * H{7, 6} ;
%%
for i = 1:7
    H{4, i} = inv(H{i,4});
end
FocalPlaneXResolution = ((2160000 / 25.4)/225)/2;
FocalPlaneYResolution = ((1611200 / 25.4)/168)/2;
ExifImageWidth = 1200;
ExifImageHeight = 900;
FocalLength = 7400/1000;

K = [FocalLength*FocalPlaneXResolution 0 ExifImageWidth/2;
     0 FocalLength*FocalPlaneYResolution ExifImageHeight/2;
     0 0 1];
save('06_data.mat', 'u', 'H', 'K');
%%
f = figure;
hold on;
for i = 2:6
    w = 0:100:1200;
    h = 0:100:900;
    
    ll = H{i,4}*[w; zeros(1, size(w, 2)); ones(1, size(w, 2))];
    
    ll(1, :) = ll(1, :)./ll(3, :);
    ll(2, :) = ll(2, :)./ll(3, :);
    
    lr = H{i,4}*[w; 900 * ones(1, size(w, 2)); ones(1, size(w, 2))];
    lr(1, :) = lr(1, :)./lr(3, :);
    lr(2, :) = lr(2, :)./lr(3, :);
    
    ul = H{i,4}*[zeros(1, size(h, 2)); h; ones(1, size(h, 2))];
    ul(1, :) = ul(1, :)./ul(3, :);
    ul(2, :) = ul(2, :)./ul(3, :);
    
    uu = H{i,4}*[1200 * ones(1, size(h, 2)); h; ones(1, size(h, 2))];
    uu(1, :) = uu(1, :)./uu(3, :);
    uu(2, :) = uu(2, :)./uu(3, :);
    
    coords = [ll, uu, fliplr(lr), fliplr(ul)];
    for j = 2: size(coords, 2)
        plot( [ coords(1, j-1) coords(1, j) ], [ coords(2, j - 1) coords(2, j) ], 'r-', 'linewidth', 2 );
    end
    text(ul(1),ul(2), sprintf('%d', i));
end
axis equal;
fig2pdf(f, '06_borders.pdf');
%%
bbxpoints = [];
for i = 3:5   
    
    ll = H{i,4}*[0; 0; 1];
    
    ll(1, :) = ll(1, :)./ll(3, :);
    ll(2, :) = ll(2, :)./ll(3, :);
    
    lr = H{i,4}*[0; 900; 1];
    lr(1, :) = lr(1, :)./lr(3, :);
    lr(2, :) = lr(2, :)./lr(3, :);
    
    ul = H{i,4}*[1200; 0; 1];
    ul(1, :) = ul(1, :)./ul(3, :);
    ul(2, :) = ul(2, :)./ul(3, :);
    
    uu = H{i,4}*[1200; 900; 1];
    uu(1, :) = uu(1, :)./uu(3, :);
    uu(2, :) = uu(2, :)./uu(3, :);
    
    bbxpoints = [bbxpoints , ll, lr, ul, uu];
end
mins = floor(min(bbxpoints, [], 2));
maxs = ceil(max(bbxpoints, [], 2));
panorama1 = uint8(zeros(maxs(2) - mins(2), maxs(1) - mins(1), 3));
%%

% for i=3:5
%     image = images{i};
%     for j=1:900
%         for k = 1:1024 
%             coords = H{i, 4}*[k; j; 1];
%             coords(1) = coords(1)/coords(3);
%             coords(2) = coords(2)/coords(3);
%             
%             coords(1) = round(coords(1)) - mins(1);
%             coords(2) = round(coords(2)) - mins(2);
%             
%             panorama1(coords(2), coords(1), :) = image(j, k, :);
%         end
%     end
% end

for k = 1:3
    image = images{k+2};
    for i = round(min(bbxpoints(2, (k-1)*4+1:k*4))):round(max(bbxpoints(2, (k-1)*4+1:k*4)))
        for j = round(min(bbxpoints(1, (k-1)*4+1:k*4))):round(max(bbxpoints(1, (k-1)*4+1:k*4)))
            coords = H{4, k+2}*[j; i; 1];
            coords(1) = round(coords(1)/coords(3));
            coords(2) = round(coords(2)/coords(3));
            if coords(2) < 1 || coords(2) > 900
                continue;
            end
            if coords(1) < 1 || coords(1) > 1200
                continue;
            end
            panorama1(i - mins(2), j - mins(1), :) = image(coords(2), coords(1), :);
        end
    end
end
imwrite(panorama1,'06_panorama.png');
%%
iK = inv(K);
bbxpoints = cell(1,7);
f = figure;
hold on;
for i = 1:7
    w = 0:100:1200;
    h = 0:100:900;
    
    ll = iK *H{i,4}*[w; zeros(1, size(w, 2)); ones(1, size(w, 2))];
    
    lr = iK *H{i,4}*[w; 900 * ones(1, size(w, 2)); ones(1, size(w, 2))];
      
    ul = iK *H{i,4}*[zeros(1, size(h, 2)); h; ones(1, size(h, 2))];
    
    uu = iK *H{i,4}*[1200 * ones(1, size(h, 2)); h; ones(1, size(h, 2))];
    
    coords = [ll, uu, fliplr(lr), fliplr(ul)];
    
    coords = K(1,1) * [atan2(coords(1,:), coords(3,:)); coords(2, :)./sqrt(coords(1,:).^2 + coords(3, :).^2)];
    
    for j = 2:size(coords, 2)
        plot( [ coords(1, j-1) coords(1, j) ], [ coords(2, j - 1) coords(2, j) ], 'r-', 'linewidth', 2 );
    end
    text(coords(1, 1), coords(2, 1) + 200, sprintf('%d', i));
    
    mins = min(coords, [], 2);
    maxs = max(coords, [], 2);
    bbxpoints{i} = [mins(1), maxs(1), mins(2), maxs(2)];
end
axis tight equal;
fig2pdf(f, '06_borders_c.pdf');
%%
bbxpoints2 = reshape([bbxpoints{:}], 4, 7);

minx = round(min(bbxpoints2(1, :)));
maxx = round(max(bbxpoints2(2, :)));
miny = round(min(bbxpoints2(3, :)));
maxy = round(max(bbxpoints2(4, :)));

panorama1 = uint8(zeros(abs(miny) + abs(maxy), abs(minx) + abs(maxx), 3));

for k = 1:7
    image = images{k};
    bbx = round(bbxpoints{k});
    for i = bbx(3):bbx(4)
        for j = bbx(1):bbx(2)
            
            theta = (j - 0)/K(1,1);
            h = (i - 0)/K(1,1);
            xs = sin(theta);
            zs = cos(theta);
            ys = h;
            
            coords = H{4, k} * K * [xs ; ys; zs];
            
            coords(1) = round( coords(1)/coords(3) );
            coords(2) = round( coords(2)/coords(3) );
            if coords(2) < 1 || coords(2) > 900
                continue;
            end
            if coords(1) < 1 || coords(1) > 1200
                continue;
            end
            panorama1(i + abs(miny), j + abs(minx), :) = image(coords(2), coords(1), :);
        end
    end
end
imwrite(panorama1,'06_panorama_c.png');