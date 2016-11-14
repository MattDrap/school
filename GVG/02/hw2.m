close all;
clc;
%%
load( 'daliborka_01-ux.mat' ); % loads all variables from the file into the workspace
img = imread( 'daliborka_01.jpg' );
ix = load('IXPoints.txt');
%%
figure;
axis equal
image( img );
hold on; % without this, the next drawing command would clear the figure
plot( u(1,:), u(2,:), '.' );
hold off
axis equal
subfig(2,2,1); % create a new figure
%plot3(x(1,:), x(2,:), x(3,:));
scatter3( x(1,:), x(2,:), x(3,:) )

[Q, points_sel, err_max, err_points, Q_all] = estimate_Q( u, x, ix );

%%
figure;
title('Maximal reproj. err. for each tested Q');
xlabel('selection index');
ylabel('log_10 of max. reproj. err. [px]');
logerr_max = log10(err_max);
plot(1:size(err_max, 1), logerr_max);
axis([0 size(err_max, 1) 0 max(logerr_max)])
fig2pdf( gcf, '02_Q_maxerr.pdf' );

figure;
image( img );
title('Original and reprojected points');
hold on; % without this, the next drawing command would clear the figure
plot( u(1,:), u(2,:), 'b.' );
plot(u(1, points_sel), u(2, points_sel), 'y.', 'Markersize', 16) %best points;
proj_x = Q*[x;ones(1, size(x, 2))];
proj_x = bsxfun(@rdivide, proj_x, proj_x(3,:));
plot(proj_x(1,:), proj_x(2,:), 'ro')
hold off
axis equal
fig2pdf( gcf, '02_Q_projections.pdf' );


figure;
image( img );
title('Reprojected erros (100x enlarged)')
e = 100* (proj_x(1:2, :) - u) ; % magnified error displacements
hold on;
plot( u(1,:), u(2,:), 'b.' );
plot(u(1, points_sel), u(2, points_sel), 'y.', 'Markersize',16) %best points;
for i = 1:size(e, 2)
    plot( [ u(1,i) u(1,i)+e(1,i) ], [ u(2,i) u(2,i)+e(2,i) ], 'r-', 'linewidth', 2 );
end
hold off;
axis equal
fig2pdf( gcf, '02_Q_projections_errors.pdf' );

reproj_error = sqrt(sum((u-proj_x(1:2, :)).^2));
figure;
hold on;
title('All point reproj. error for best Q');
xlabel('Reproj. error [px]');
ylabel('point index');
plot(1:size(reproj_error, 2), reproj_error);
hold off;
axis([1 size(reproj_error, 2) 0 max(reproj_error)]);
fig2pdf( gcf, '02_Q_pointerr.pdf' );