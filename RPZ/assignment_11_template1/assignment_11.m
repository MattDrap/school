% Assignment 11: EM algorithm

%% Init
run('../stprtool/stprpath.m')

%% Load data
load image_data.mat
r = 10;
m = [10, 100, 500];
w = 36;

%%
rng(12);
for I=1:length(m)
    [f{I},d{I},b{I},L{I}] = run_EM(images, m(I), w);
end

% plot L and save it to L_10.png
plot(L{1});
print('L_10.png', '-dpng');
%%

for I=1:length(m)
    [optf{I}, optd{I}, optb{I}, optL{I}] = identify_villain(images, m(I), r, w);
end
% save optf{I} to face10.png, face100.png and face500.png
imshow(uint8(optf{1}));
print('face10.png', '-dpng');
imshow(uint8(optf{2}));
print('face100.png', '-dpng');
imshow(uint8(optf{3}));
print('face500.png', '-dpng');
%%
% plot optd{3}(1:10) into the first 10 images and save it as d1.png, ...,
% d10.png
pld = optd{3};
for i = 1:10
    figure;
    imshow(images(:,:,i),[0,255]);
    rectangle('Position', [pld(i), 0.5, w, size(images, 1)] ,'EdgeColor','r')
    hold on;
    plot(pld(i));
    hold off;
    print(sprintf('%s%d%s', 'd', i, '.png'), '-dpng');
end