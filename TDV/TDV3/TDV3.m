% K = [  4.30662478e+03,   0.00000000e+00,   2.59136950e+03 / 2;
%       0,   4.32151461e+03,   1.42629560e+03 / 2 ;
%       0,   0,   1];
K = [[  2.15102295e+03,  0   1.29395810e+03],
[  0  2.15892669e+03   7.13809453e+02],
[  0  0   1.00000000e+00]];
  addpath('../p5');
  addpath('../TDV2');
  addpath('../Misc');
  addpath('../toolbox');
if( ~exist( 'p5gb', 'file' ) )
  error( 'Cannot find five-point estimator. Probably PATH is not set.' );
end
pick1 = 4;
pick2 = 5;

load('Corr.mat');
[R, t,F,inl] = ransac_e(matchmatrix{pick1, pick2}, K, 2.5, 0.99);
P1 = K*[eye(3,3), zeros(3,1)];
P2 = K*R*[eye(3,3), -t];
%%

corresp = matchmatrix{pick1, pick2};
u1 = e2p(corresp(1:2, :));
u2 = e2p(corresp(3:4, :));

list = dir('../IMG_D');
list_dirs = {list.isdir};
list_names = {list.name};
image_names = list_names(cellfun(@(p) p ~= true, list_dirs));

pick = {pick1, pick2};
for j = 1:2
    im1 = imread(['../IMG_D/' image_names{pick{j}}]);
    figure;
    image(im1);
    hold on;

    for i = 1:floor(size(u1, 2) / 1000):size(u1, 2)
        if inl(i)
            inlier = plot([u1(1, i), u2(1, i)], [u1(2, i), u2(2, i)], 'r');
        else
            outlier = plot([u1(1, i), u2(1, i)], [u1(2, i), u2(2, i)], 'k');
        end
    end
    title(sprintf('Obrázek %d', pick{j}) );
    legend([inlier, outlier], 'Inliery', 'Outliery');
end
%%
u1inl = u1(:, inl);
u2inl = u2(:, inl);
l2 = F*u1inl;
l1 = F'*u2inl;
l = {l1, l2};
cols = {[1 1 0]', [1 0 1]', [0 1 1]', [1 0 0]', [0 1 0]', [0 0 1]', [1 1 1]', [0 0 0]',[0.5 1 0]', [0 0.5 1]', [0 1 0.5]', [1 0 0.5]'};
uinl = {u1inl, u2inl};
for j = 1:2
    im1 = imread(['../IMG_D/' image_names{pick{j}}]);
    [Height, Width, ~] = size(im1);
    Bbox = [1, Width;
            1, Height];
    figure;
    image(im1);
    
    hold on;
    
    p1 = uinl{j};
    lines = l{j};
    for i = 1:floor(size(p1, 2) / 20):size(p1, 2)
        plot(p1(1, i), p1(2, i), 'Color', cols{mod(i, 12) + 1});
        [ll1, ll2] = getLineLine(lines(:, i), Bbox);
        plot([ll1(1), ll2(1)], [ll1(2) ll2(2)], 'Color', cols{mod(i, 12) + 1});
    end
    title(sprintf('Obrázek %d', pick{j}) );
end