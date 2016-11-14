% Assignment 11: EM algorithm

%% Init
%run('../../stprtool/stprpath.m')

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

%%

for I=1:length(m)
    [optf{I}, optd{I}, optb{I}, optL{I}] = identify_villain(X, m(I), r, w);
end
% save optf{I} to face10.png, face100.png and face500.png

%%
% plot optd{3}(1:10) into the first 10 images and save it as d1.png, ...,
% d10.png
