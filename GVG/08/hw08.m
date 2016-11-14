close all;

ims = cell(2,1);
ims{1} = imread('daliborka_01.jpg');
ims{2} = imread('daliborka_23.jpg');

if ~exist('08_mdata.mat')
    mu = edit_points(ims, [], []);
    mu1 = mu{1};
    mu2 = mu{2};
    save('08_mdata.mat','mu1', 'mu2');
else
    load('08_mdata.mat');
end

if ~exist('08_mdata2.mat')
    mu = edit_points(ims, [], []);
    meshu1 = mu{1};
    meshu2 = mu{2};
    save('08_mdata2.mat','meshu1', 'meshu2');
else
    load('08_mdata2.mat');
end

u1 = [mu1, meshu1];
u2 = [mu2, meshu2];
point_sel = 1:12;
[F,G, err] = u2Foptim(u1, u2, point_sel);

au1h = [u1; ones(1, size(u1, 2))];
au2h = [u2; ones(1, size(u2, 2))];

l2 = F * au1h;
l1 = F' * au2h;

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
fig2pdf(f, '08_eg.pdf');
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
fig2pdf(f, '08_errors.pdf');

save('08_data.mat', 'point_sel', 'u1', 'u2', 'F', 'G');