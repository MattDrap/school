C = [1;2;-3];
f=1;
R = diag( [1 1 1] );
K = R;
X1 = [0 0 0]';
X2 = [1 0 0]';
X3 = [0 1 0]';

X = [X1, X2, X3];
X = [X; ones(1, 3)];

P = [K*R, -K*R*C];
X_star = P*X;

invK = inv(K);
KTK = invK'*invK;

Xtest = bsxfun(@rdivide, X_star, X_star(3,:));

c = zeros(3,1);
d = zeros(3,1);
for i = 1:3
    j = mod(i, 3) + 1;
    c(i) = ( Xtest(:,i)' * KTK * Xtest(:, j) ) / ...
        (norm(invK * Xtest(:, i)) * norm(invK * Xtest(:, j))); 
    d(i) = sqrt(sum((X(:, i) - X(:, j)).^2));
end

[N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c(1), c(2), c(3));

N = [N1(1), N2(1), N3(1)];
[R2, C2] = p3p_RC(N, Xtest(1:2, :), X(1:3, :), K);

%%
Dalib = load( 'daliborka_01-ux.mat' );
ix = load('IXPoints.txt');
load('K.mat');
allX = Dalib.x;
allX = [allX; ones(1, size(allX, 2))];
ind = nchoosek(ix, 3);

bestR = [];
bestC = [];
sel_points = [];
best = Inf;

max_errors = [];
allCs = [];

invK = inv(K);
KTK = invK'*invK;

for k = 1:size(ind, 1)
    mpoints = Dalib.x(:, ind(k, :));
    c = zeros(3,1);
    d = zeros(3,1);
    mupoints = Dalib.u(:, ind(k, :));
    muh = [mupoints; [1,1,1]];
    for i = 1:3
        j = mod(i, 3) + 1;
        c(i) = ( muh(:,i)' * KTK * muh(:, j) ) / ...
            (norm(invK * muh(:, i)) * norm(invK * muh(:, j))); 
        
        d(i) = sqrt(sum((mpoints(:, i) - mpoints(:, j)).^2));
    end

    [N1, N2, N3] = p3p_distances(d(1), d(2), d(3), c(1), c(2), c(3));
    
    for i = 1:size(N1, 2);
        [R2, C2] = p3p_RC([N1(i), N2(i), N3(i)], mupoints, mpoints, K);
        P = [K*R2, -K*R2*C2];
        proj_x = P*allX;
        proj_x = bsxfun(@rdivide, proj_x, proj_x(3,:));
        errors = sqrt(sum((Dalib.u-proj_x(1:2, :)).^2));
        max_error = max(errors);
        max_errors = [max_errors, max_error];
        allCs(:, end + 1) = C2;
        if max_error < best
            best = max_error;
            bestR = R2;
            bestC = C2;
            sel_points = ind(k, :);
        end
    end
end
R = bestR;
C = bestC;
point_sel = sel_points;
save( '04_p3p.mat', 'R', 'C', 'point_sel', '-v6' );

%%

P = [K*R, -K*R*C];

proj_x = P*allX;
proj_x = bsxfun(@rdivide, proj_x, proj_x(3,:));

img = imread('daliborka_01.jpg');

figure;
image( img );
title('Reprojected erros (100x enlarged)')
e = 100* (proj_x(1:2, :) - Dalib.u) ; % magnified error displacements
hold on;
plot( Dalib.u(1,:), Dalib.u(2,:), 'b.' );
plot(Dalib.u(1, point_sel), Dalib.u(2, point_sel), 'y.', 'Markersize',16) %best points;
for i = 1:size(e, 2)
    plot( [ Dalib.u(1,i) Dalib.u(1,i)+e(1,i) ], [ Dalib.u(2,i) Dalib.u(2,i)+e(2,i) ], 'r-', 'linewidth', 2 );
end
hold off;
axis equal
fig2pdf( gcf, '04_RC_projections_errors.pdf' );
%%
fig2 = figure;
logmaxerrors = log10(max_errors);
scatter(1:size(logmaxerrors, 2), logmaxerrors);
fig2pdf( fig2, '04_RC_maxerr.pdf' );

%%
errors = sqrt(sum((Dalib.u-proj_x(1:2, :)).^2));
fig3 = figure;
plot(errors)
fig2pdf( fig3, '04_RC_pointerr.pdf' );
%%
Delta = eye(3,3);
Epsilon = Delta * inv(R);

fig4 = figure;
hold on;
plot_csystem(Delta, [0,0,0], 'k', '\delta');
plot_csystem(Epsilon, C, 'm', '\epsilon');
scatter3(Dalib.x(1, :), Dalib.x(2, :), Dalib.x(3,:), 'b');
scatter3(allCs(1, :), allCs(2, :), allCs(3, :), 'r');
hold off;
fig2pdf( fig4, '04_scene.pdf' );