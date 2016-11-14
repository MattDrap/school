   
%% timestamp
fprintf(1,'Started on %s\n', datestr(now));

%% load ease case
load('im1_harris.mat'); pts1=pts;
load('im2_harris.mat'); pts2=pts;
im1=im2double(rgb2gray(imread('img1.png')));
im2=im2double(rgb2gray(imread('img2.png')));

%% find tentative correspondences method mutually closest descriptions

matchpar.threshold=inf;
matchpar.method='mutual';

fprintf('Find correspondences using mutually nearest matching...\n');
tic
corr=match(pts1, pts2, matchpar);
t=toc;

fprintf('Found %d tentative correspondences in %.3f sec.\n', size(corr,2), t);
u=corr2u(pts1, pts2, corr);

%% run RANSAC to find consistent matches

% RANSAC is a randomized algorithm, repeat run three times.
tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);
H=H./H(3,3)

%% load hard case

load('im1_mser.mat'); pts1=pts;
load('im2_mser.mat'); pts2=pts;
im1=im2double(rgb2gray(imread('img1.png')));
im2=im2double(rgb2gray(imread('img5.png')));

%% find tentative correspondences method stable closest descriptions

matchpar.threshold=inf;
matchpar.method='stable';

fprintf('\nFind correspondences using weak stable matching...\n');
tic
corr=match(pts1, pts2, matchpar);
t=toc;

fprintf('Found %d tentative correspondences in %.3f sec.\n', size(corr,2), t);
u=corr2u(pts1, pts2, corr);

%% run RANSAC to find consistent matches

% RANSAC is a randomized algorithm, repeat run three times.
tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);
H=H./H(3,3)
showcorrs(im1,im2,u, inl);

%% find tentative correspondences method stable closest descriptions

matchpar.threshold=inf;
matchpar.method='sclosest';

fprintf('\nFind correspondences using second closest matching...\n');
tic
corr=match(pts1, pts2, matchpar);
t=toc;

fprintf('Found %d tentative correspondences in %.3f sec.\n', size(corr,2), t);
u=corr2u(pts1, pts2, corr);

%% run RANSAC to find consistent matches

% RANSAC is a randomized algorithm, repeat run three times.
tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [H inl]=ransac_h(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);
H=H./H(3,3)
showcorrs(im1,im2,u, inl);

%% distance of inliers, can differ depending on best found H
dist=sqrt(hdist(H,u(:,inl)))

%% load non planar case

load('im1f_mser.mat'); pts1=pts;
load('im2f_mser.mat'); pts2=pts;
im1=im2double(rgb2gray(imread('washA.png')));
im2=im2double(rgb2gray(imread('washB.png')));

%% find tentative correspondences method stable closest descriptions

matchpar.threshold=inf;
matchpar.method='sclosest';

fprintf('\nFind correspondences using second closest matching...\n');
tic
corr=match(pts1, pts2, matchpar);
t=toc;

fprintf('Found %d tentative correspondences in %.3f sec.\n', size(corr,2), t);
u=corr2u(pts1, pts2, corr);

%% run RANSAC to find consistent matches

% RANSAC is a randomized algorithm, repeat run three times.
tic; [F inl]=ransac_f(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [F inl]=ransac_f(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);

tic; [F inl]=ransac_f(u, 5, 0.99); t=toc;
fprintf('Found %d inliers %.2f percent of tentative correspondences in %.3f sec.\n', sum(inl), 100*sum(inl)/size(corr,2), t);
showcorrs(im1,im2, u, inl);