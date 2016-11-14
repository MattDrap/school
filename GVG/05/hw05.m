close all;
u =  [0 0 1 1;
      0 1 1 0];
u0 = [1 2 1.5 1;
      1 2 0.5 0];
H = u2H(u, u0);
P = imread('pokemon_00.jpg');
Pd = imread('pokemon_03.jpg');
ims = {P, Pd};
if ~exist('points.mat')
    ps = edit_points(ims, [], []);
    u = ps{2};
    u0 = ps{1};
else
    load('points.mat');
end
%%
[H, point_sel, error] = u2h_optim(u, u0);

save( '05_homography.mat', 'H', 'u', 'u0', 'point_sel', '-v6' );
Pdg = rgb2gray(Pd);
d = Pdg < 30;
se = strel('disk',1, 8);
closeBW = imclose(d, se);
%imshow(closeBW);
[y,x] = find(closeBW);
x_ = H(1,1)*x + H(1,2)*y + H(1,3);
y_ = H(2,1)*x + H(2,2)*y + H(2,3);
w_ = H(3,1)*x + H(3,2)*y + H(3,3);

x_ = x_ ./ w_;
y_ = y_ ./ w_;

Pd2 = Pd;

y_r = round(y_);
x_r = round(x_);

lesser = (y_r < 1);
x_r(lesser) = []; y_r(lesser) = []; x(lesser) = []; y(lesser) = [];
lesser = (x_r < 1);
x_r(lesser) = []; y_r(lesser) = []; x(lesser) = []; y(lesser) = [];
lesser = (y_r >= size(P, 1));
x_r(lesser) = []; y_r(lesser) = []; x(lesser) = []; y(lesser) = [];
lesser = (x_r >= size(P, 2));
x_r(lesser) = []; y_r(lesser) = []; x(lesser) = []; y(lesser) = [];

mr = max(max(Pd2(:,:, 1)));
mg = max(max(Pd2(:,:, 2)));
mb = max(max(Pd2(:,:, 3)));

for i = 1:size(x, 1)
    Pd2(y(i),x(i), 1) = double(P(y_r(i), x_r(i), 1))/255 * mr;
    Pd2(y(i),x(i), 2) = double(P(y_r(i), x_r(i), 2))/255 * mg;
    Pd2(y(i),x(i), 3) = double(P(y_r(i), x_r(i), 3))/255 * mb;
end

fig = figure();
imshow(Pd2);
print(fig, '-dpng', '05_corrected.png');

%% Create figure
ims = {P, Pd2};
opt.x_style = { 'marker', 'x', 'color', 'r', 'markersize', 8 };
opt.text_style = { 'backgroundcolor', [1 0.6 0.6], ...
                   'fontsize', 12 };
opt.specialx_style = { 'marker', 'o',  'MarkerEdgeColor','r',...
                'MarkerFaceColor', 'y' , 'markersize', 8};
opt.specialtext_style = { 'backgroundcolor', 'r', ...
                   'fontsize', 12, 'color', 'y'};
us = {u0, u};
fig = figure;
colormap gray
ax = {};
s = subplot(1,2,1);
hold on;
ax{1} = s;
subimage( ims{1} )
axis equal
title('Labeled points in image');
ylabel('y[px]');
xlabel('x[px]');
hold on

s2 = subplot(1,2,2);
ax{2} = s2;
subimage( ims{2} )
axis equal
title('Labeled points in reference image');
ylabel('y[px]');
xlabel('x[px]');
hold on

for j = 1:numel( ims )
  set( fig, 'currentaxes',  ax{j} );
  
  for i = 1:size( us{j}, 2 )
      up = us{j}(:,i);
      if any(i==point_sel)
        plot( up(1), up(2), opt.specialx_style{:});
    
        text( up(1), up(2) - 30, sprintf( '%i', i ), ...
             'verticalalign', 'bottom', 'horizontalalign', 'center', ...
             opt.specialtext_style{:});

      else
        plot( up(1), up(2), opt.x_style{:});
    
        text( up(1), up(2) - 30, sprintf( '%i', i ), ...
             'verticalalign', 'bottom', 'horizontalalign', 'center', ...
             opt.text_style{:});

      end
  end
end
fig2pdf(fig, '05_homography.pdf');