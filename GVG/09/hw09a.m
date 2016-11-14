close all;

ims = cell(2,1);
ims{1} = imread('daliborka_01.jpg');
ims{2} = imread('daliborka_23.jpg');

load('08_data.mat');
load('K.mat');
Ex = K' * F * K;
[U, D, V] = svd( Ex ); 
D(2,2) = D(1,1);
Ex = U * D * V';
iK = inv(K);
Fx = iK' * Ex * iK;

au1h = [u1; ones(1, size(u1, 2))];
au2h = [u2; ones(1, size(u2, 2))];

l2 = Fx * au1h;
l1 = Fx' * au2h;

%%
cols = {[1 1 0]', [1 0 1]', [0 1 1]', [1 0 0]', [0 1 0]', [0 0 1]', [1 1 1]', [0 0 0]',[0.5 1 0]', [0 0.5 1]', [0 1 0.5]', [1 0 0.5]'};
[Height, Width, Color] = size(ims{1});
f = figure;
hold on;
f1 = subplot(1, 2, 1);
imagesc(ims{1});
axis equal;
f2 = subplot(1, 2, 2);
imagesc(ims{2});
axis equal;
for i = 1:size(point_sel, 2)
    set( f, 'currentaxes',  f1 );
    hold on;
    plot(u1(1, point_sel(i)), u1(2, point_sel(i)), 'x', 'Color', cols{i});
    drawLine(l1(:, point_sel(i)), cols{i}, Width, Height);
    set( f, 'currentaxes',  f2 );
    hold on;
    plot(u2(1, point_sel(i)), u2(2, point_sel(i)), 'x', 'Color', cols{i});
    drawLine(l2(:, point_sel(i)), cols{i}, Width, Height);
end
fig2pdf(f, '09_egx.pdf');
%%
for j = 1:size(au1h, 2)
    dist1(j) = abs(l1(:, j)'*au1h(:, j))/(sqrt(l1(1,j).^2 + l1(2, j).^2).*au1h(3,j));
    dist2(j) = abs(l2(:, j)'*au2h(:, j))/(sqrt(l2(1,j).^2 + l2(2,j).^2).*au2h(3,j));
end

f = figure;
hold on;
plot(1:length(dist1), dist1);
plot(1:length(dist2), dist2);
axis tight;
xlabel('point index');
ylabel('epipolar err. proj');
legend('image1', 'image2');
hold off;
fig2pdf(f, '09_errorsx.pdf');

%%
[Fe, E] = u2Foptim(u1, u2, point_sel, K);

l2 = Fe * au1h;
l1 = Fe' * au2h;

f = figure;
hold on;
f1 = subplot(1, 2, 1);
imagesc(ims{1});
axis equal;
f2 = subplot(1, 2, 2);
imagesc(ims{2});
axis equal;
for i = 1:size(point_sel, 2)
    set( f, 'currentaxes',  f1 );
    hold on;
    plot(u1(1, point_sel(i)), u1(2, point_sel(i)), 'x', 'Color', cols{i});
    drawLine(l1(:, point_sel(i)), cols{i}, Width, Height);
    set( f, 'currentaxes',  f2 );
    hold on;
    plot(u2(1, point_sel(i)), u2(2, point_sel(i)), 'x', 'Color', cols{i});
    drawLine(l2(:, point_sel(i)), cols{i}, Width, Height);
end
fig2pdf(f, '09_eg.pdf');
%%
for j = 1:size(au1h, 2)
    dist1(j) = abs(l1(:, j)'*au1h(:, j))/(sqrt(l1(1,j).^2 + l1(2, j).^2).*au1h(3,j));
    dist2(j) = abs(l2(:, j)'*au2h(:, j))/(sqrt(l2(1,j).^2 + l2(2,j).^2).*au2h(3,j));
end

f = figure;
hold on;
plot(1:length(dist1), dist1);
plot(1:length(dist2), dist2);
axis tight;
xlabel('point index');
ylabel('epipolar err. proj');
legend('image1', 'image2');
hold off;
fig2pdf(f, '09_errors.pdf');

save('09a_data.mat', 'F', 'Ex', 'Fx', 'E', 'Fe', 'u1', 'u2', 'point_sel');