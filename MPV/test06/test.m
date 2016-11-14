   
%% timestamp
fprintf(1,'Started on %s\n', datestr(now));

%% load data and create inverted file

% path to the preprocessed data
load('mpvdb_haff2.mat');
idf = getidf(VW, 10000);
DB  = createdb_tfidf(VW, 10000, idf);

opt = [];
opt.max_tc=600;
opt.max_MxN=10;
opt.max_spatial=50;
% directory where you unzipped mpvimgs.zip
opt.root_dir='../';
% opt.subplot=1;
opt.threshold=8;

%% check corrm2m correspondences on a single pair

qid = 290;
did = 340;
bbx = [780 625 940 720];

im1 = im2double(rgb2gray(imread(fullfile(opt.root_dir, NAMES{qid}))));
im2 = im2double(rgb2gray(imread(fullfile(opt.root_dir, NAMES{did}))));

qidx = ptsinbbx(GEOM{qid}, bbx);
corrs = corrm2m(VW{qid}(qidx), VW, did, opt); corr=corrs{1};

qgeom = GEOM{qid}(:,qidx);
dgeom = GEOM{did};

showcorrs(im1, qgeom, im2, dgeom, corr, 1:size(corr,2));
showbbx(bbx, eye(3));

fprintf('\nTentative correspondences: '); fprintf(1, '(%d,%d) ',corr); fprintf(1,'\n');

%% check ransacm2m on a single pair

qgeom = GEOM{qid}(:,qidx);
dgeom = GEOM{did};

[score A] = ransacm2m(qgeom, GEOM, corrs, did, opt);

pts1=qgeom(1:2,corr(1,:)); pts1(3,:)=1;
pts2=dgeom(1:2,corr(2,:)); pts2(3,:)=1;

threshold = opt.threshold*opt.threshold;

inl = adist(A, pts1, pts2)<threshold;

showcorrs(im1, qgeom, im2, dgeom, corr, inl);
showbbx(bbx, eye(3));
showbbx(bbx, A, double([SIZES(1,qid)+10+1 1]));

fprintf('\nInlier pairs: '); fprintf(1, '(%d,%d) ',corr(:,inl)); fprintf(1,'\n');

%% process few queries, planar object

qid = 100;
bbx = [188 415 846 745];
tic
[scores, img_ids, A]=querysp(VW{qid}, GEOM{qid}, bbx, VW, GEOM, DB, idf, opt);
toc
% show top 5 results
showresults(img_ids(1:5), scores, A, bbx, opt, NAMES);
fprintf('\nTop 5 scores: '); fprintf(1, '%f ',scores(1:5)); fprintf(1,'\n');
fprintf('\nTop 5 ids: '); fprintf(1, '%d ',img_ids(1:5)); fprintf(1,'\n');

%% part of planar object
qid = 1;
bbx = [744  206  850  596];
tic
[scores, img_ids, A]=querysp(VW{qid}, GEOM{qid}, bbx, VW, GEOM, DB, idf, opt);
toc

% show top 5 results
showresults(img_ids(1:5), scores, A, bbx, opt, NAMES);
fprintf('\nTop 5 scores: '); fprintf(1, '%f ',scores(1:5)); fprintf(1,'\n');
fprintf('\nTop 5 ids: '); fprintf(1, '%d ',img_ids(1:5)); fprintf(1,'\n');

%% UK bench
qid = 831;
bbx = [124 22 297 217];
tic
[scores, img_ids, A]=querysp(VW{qid}, GEOM{qid}, bbx, VW, GEOM, DB, idf, opt);
toc
% show top 5 results
showresults(img_ids(1:5), scores, A, bbx, opt, NAMES);
fprintf('\nTop 5 scores: '); fprintf(1, '%f ',scores(1:5)); fprintf(1,'\n');
fprintf('\nTop 5 ids: '); fprintf(1, '%d ',img_ids(1:5)); fprintf(1,'\n');

%% can we find all pokemons?
qid = 280;
bbx = [338  377  480  510];
% verification performance test
opt.max_spatial=100;
tic
[scores, img_ids, A]=querysp(VW{qid}, GEOM{qid}, bbx, VW, GEOM, DB, idf, opt);
toc;
% show last 5 good results (in case we have all out of 73 pokemon images)
showresults(img_ids(68:73), scores(68:73), A(:,:,68:73), bbx, opt, NAMES);
fprintf('\nScores: '); fprintf(1, '%f ',scores(68:73)); fprintf(1,'\n');
fprintf('\nIds: '); fprintf(1, '%d ',img_ids(68:73)); fprintf(1,'\n');

%% query expansion? without...
qid = 67;
bbx = [370   464   495   564];

opt.max_spatial=20;
tic
[scores, img_ids, A]=querysp(VW{qid}, GEOM{qid}, bbx, VW, GEOM, DB, idf, opt);
toc

% show top 5 results
showresults(img_ids(1:5), scores, A, bbx, opt, NAMES);
fprintf('\nTop 5 scores: '); fprintf(1, '%f ',scores(1:5)); fprintf(1,'\n');
fprintf('\nTop 5 ids: '); fprintf(1, '%d ',img_ids(1:5)); fprintf(1,'\n');

%% query expansion? with...
opt.max_qe=5;
tic
[scores, img_ids, A]=querysp(VW{qid}, GEOM{qid}, bbx, VW, GEOM, DB, idf, opt);
toc
% show top 5 results
showresults(img_ids(1:5), scores, A, bbx, opt, NAMES);
fprintf('\nTop 5 scores: '); fprintf(1, '%f ',scores(1:5)); fprintf(1,'\n');
fprintf('\nTop 5 ids: '); fprintf(1, '%d ',img_ids(1:5)); fprintf(1,'\n');
