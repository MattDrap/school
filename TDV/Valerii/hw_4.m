clear; close all; clc;

%%
addpath('..\p5');
addpath('..\ba'); %bundle adjustment
addpath('..\corresp');
addpath('..\p3p');
addpath('..\toolbox_tdv')

%%
K = [[  2.15102295e+03  0   1.29395810e+03],
[  0   2.15892669e+03   7.13809453e+02],
[  0   0  1.00000000e+00]];

load('Corr.mat');

N = 12;
thr = 25;
conf = 0.95;

%% Find two images based on best correspondences
%pts_ind = pair_by_best_corr( correspondences );
% pts_ind = sort(randsample(N,2));
pts_ind = [4 5];
fprintf('Looking for E for images { %s and %s }\n', num2str(pts_ind(1)), num2str(pts_ind(2)));
pair_data = matchmatrix{pts_ind(1), pts_ind(2)};

pts1 = e2p(pair_data(1:2,:));
pts2 = e2p(pair_data(3:4,:));

pts1_norm = K\pts1;
pts2_norm = K\pts2;

%% Finding E using ransac
[E, best_inl, P1, P2] = ransac_E(K, pts1_norm, pts2_norm, thr, conf);

%% Perform initial settings

camera_num = 12;
% Initialise correspondence tools with a number of cameras
fprintf('Initialise correspondences tool\n');
corresp = corresp_init(camera_num);

ind = nchoosek(1:camera_num, 2);

for iRow = 1:size(ind, 1)
    curPair = ind(iRow,:);
    corresp = corresp_add_pair(corresp, curPair(1), curPair(2), correspondences{curPair(1), curPair(2)}.match_pts');
end

%% get all points from all images
if ~exist('U_all.mat','file') 
    U_all = cell(camera_num, 1);
    for iRow = 1:camera_num
        U_all{iRow} = get_pts_in_img(iRow);
    end
    save('U_all.mat','U_all');
else
    load('U_all.mat');
end

%% Perform camera gluing
[cameras, Xcloud, report_info] = camera_gluing( P1, P2, K, U_all, best_inl, camera_num, corresp, correspondences, pts_ind(1), pts_ind(2), conf );
% [cameras, Xcloud, report_info] = camera_gluing_last_ba( P1, P2, K, U_all, best_inl, camera_num, corresp, correspondences, pts_ind(1), pts_ind(2), conf );
save('4_cameras.mat','cameras','Xcloud','report_info');

%% Plot cameras and point cloud
plot_cameras_and_cloud( K, cameras, Xcloud, pts_ind, report_info );
%%
fig2pdf( gcf, 'cameras_and_points_cloud.pdf' )
%%
save('4_all_data.mat');
