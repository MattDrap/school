close all;
addpath('../Misc');
addpath('../Misc/WBS');
addpath('../Misc/WBS/wbs');

if( ~exist( 'wbs_default_cfg', 'file' ) )
  error( 'Cannot find WBS matcher. Probably PATH is not set.' );
end

fprintf( 'Reading images ...\n' )
im1=imread('book1.png');
im2=imread('book2.png');


% compute image descriptors
fprintf( 'Computing descriptors ...\n' )
cfg  = wbs_default_cfg;
pts1 = wbs_describe_image(im1, cfg);
pts2 = wbs_describe_image(im2, cfg);


fprintf( 'Matching ...\n' )
% match all pairs using precomputed descriptions
[ pc12 m12 ] = wbs_match_descriptions( pts1, pts2, cfg );
%%
[Ha, inl, Hb, inl2, common_line] = ransac_h2(pc12, 0.9, 0.9);
%%
u = pc12(1:2, :);
u2 = p2e(inv(Hb)*e2p(pc12(3:4, :)));

%%
[H,W] = size(im1);
extents = [1, W;
           1, H];

figure;
imshow(im1);
hold on;

[minp1, minp2] = getLineLine(common_line, extents);
if ~isnan(minp1)
    plot([minp1(1), minp2(1)], [minp1(2), minp2(2)], 'c');
end


greens1 = u(:, inl);
greens2 = u2(:, inl);

du = u(:, ~inl);
du2 = u2(:, ~inl);

red1 = du(:, inl2);
red2 = du2(:, inl2);

ddu = du(:, ~inl2);
ddu2 = du2(:, ~inl2);
%%
quiver(ddu(1, :),ddu(2, :), ddu2(1, :), ddu2(2, :), 'k');
quiver(red1(1, :),red1(2, :), red2(1, :), red2(2, :), 'r');
quiver(greens1(1, :),greens1(2, :), greens2(1, :), greens2(2, :), 'g');
%%
%%
u2 = pc12(3:4, :);
u = p2e(Ha*e2p(pc12(1:2, :)));

%%
[H,W] = size(im2);
extents = [1, W;
           1, H];

figure;
imshow(im2);
hold on;

common_line2 = inv(Ha') * common_line;
[minp1, minp2] = getLineLine(common_line2, extents);
if ~isnan(minp1)
    plot([minp1(1), minp2(1)], [minp1(2), minp2(2)], 'c');
end


greens1 = u(:, inl);
greens2 = u2(:, inl);

du = u(:, ~inl);
du2 = u2(:, ~inl);

red1 = du(:, inl2);
red2 = du2(:, inl2);

ddu = du(:, ~inl2);
ddu2 = du2(:, ~inl2);
%%
quiver(ddu2(1, :),ddu2(2, :), ddu(1, :), ddu(2, :), 'k');
quiver(red2(1, :),red2(2, :), red1(1, :), red1(2, :), 'r');
quiver(greens2(1, :),greens2(2, :), greens1(1, :), greens1(2, :), 'g');