close all;
clc;

img = imread( 'daliborka_01.jpg' ); % load the image
subfig(2,2,1); % create a new figure
image( img ); % display the image, keep axes visible
axis image % display it with square pixels

u2 = load('u2.txt');

if( ~exist( 'my_points.mat', 'file' ) )
  [x, y] = ginput( 7 );
  save( 'my_points.mat', 'x', 'y' );
else
  load( 'my_points.mat' );
end

u = [x';y'];
%%
img2 = img;

colors = [255,  0,  0;
          0,    255,0;
          0,    0,  255;
          255,  0,  255;
          0,    255,255;
          255,  255,0;
          255,  255,255];
%%
for i = 1:size(u,2)
    img2(round(u(2, i)), round(u(1, i)), :) = colors(i, :);
end
imwrite(img2, '01_daliborka_points.png');
A = estimate_A( u2, u ); % u2 and u are 2xn matrices

u2homo = [u2; ones(1,size(u,2))];
ux = A*u2homo;
e = 100 * ( ux - u ); % magnified error displacements
hold on % to plot over the image
for i = 1:size(u,2)
    plot( u(1,i), u(2,i), 'o', 'linewidth', 2, 'color', colors(i, :)/255 ) 
    plot( [ u(1,i) u(1,i)+e(1,i) ], [ u(2,i) u(2,i)+e(2,i) ], 'r-', 'linewidth', 2 );
end
hold off

fig2pdf( gcf, '01_daliborka_errs.pdf' );
save( '01_points.mat', 'u', 'A' );
