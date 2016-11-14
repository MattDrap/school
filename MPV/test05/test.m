   
%% timestamp
fprintf(1,'Started on %s\n', datestr(now));

%% load kmeans data

load('data2d.mat');
plot(data(1,:),data(2,:),'g.', 'markersize', 10);
set(gca, 'xtick', [], 'ytick', []); axis image;

%% kmeans
tic
means=kmeans(4, data)
toc

figure;
plot(data(1,:),data(2,:),'g.','markersize', 10); hold on;
plot(means(1,:),means(2,:),'rx', 'linewidth', 3, 'markersize', 15);
% visualise voronoi cells
h=voronoi(means(1,:), means(2,:)); delete(h(1));
set(gca, 'xtick', [], 'ytick', []); axis image;

%% assign to labels using nearest

tic
[lbls dists] = nearest(means, data);
toc

figure; hold on;
h=voronoi(means(1,:), means(2,:)); delete(h(1));
plot(data(1,lbls==1),data(2,lbls==1),'b.','markersize', 10);
plot(data(1,lbls==2),data(2,lbls==2),'g.','markersize', 10);
plot(data(1,lbls==3),data(2,lbls==3),'r.','markersize', 10);
plot(data(1,lbls==4),data(2,lbls==4),'k.','markersize', 10);
set(gca, 'xtick', [], 'ytick', []); axis image;

%% load centers of sshessian detektor and SIFT descriptor
load('hess_centers10k.mat');
load('realdata.mat');

%% create tf database, check consistency
tic
DB=createdb(lbls, 10000);
toc

fprintf(1, 'Lenghts of #2: %f, #18: %f, #30: %f\n', full([sum(DB(2,:).^2), sum(DB(18,:).^2), sum(DB(30,:).^2)]));
weights=full(DB(2,find(DB(2,:))));

fprintf(1, 'Weights img #2: '); fprintf(1, '%f ', weights(1:10)); fprintf(1, '\n\n');

%% query with few random documents
idf=ones(1,10000);
tic
[idxs scores]=query(DB, lbls{2}, idf);
toc

fprintf(1, 'Ordering with query #2: '); fprintf(1, '%d ', idxs(1:10)); fprintf(1, '\n');
fprintf(1, 'Scores with query #2: '); fprintf(1, '%f ', scores(1:10)); fprintf(1, '\n\n');

[idxs scores]=query(DB, lbls{18}, idf);
fprintf(1, 'Ordering with query #18: '); fprintf(1, '%d ', idxs(1:10)); fprintf(1, '\n');
fprintf(1, 'Scores with query #18: '); fprintf(1, '%f ', scores(1:10)); fprintf(1, '\n\n');

[idxs scores]=query(DB, lbls{30}, idf);
fprintf(1, 'Ordering with query #30: '); fprintf(1, '%d ', idxs(1:10)); fprintf(1, '\n');
fprintf(1, 'Scores with query #30: '); fprintf(1, '%f ', scores(1:10)); fprintf(1, '\n\n');

%% create tf-idf database, check consistency
idf=getidf(lbls, 10000);
fprintf(1, 'IDF weights of first 10 visual words: '); fprintf(1, '%f ', idf(1:10)); fprintf(1, '\n\n');

tic
DB=createdb_tfidf(lbls, 10000, idf);
toc

fprintf(1, 'Lenghts of #2: %f, #8: %f, #10: %f\n', full([sum(DB(2,:).^2), sum(DB(18,:).^2), sum(DB(30,:).^2)]));
weights=full(DB(2,find(DB(2,:))));

fprintf(1, 'Weights img #2: '); fprintf(1, '%f ', weights(1:10)); fprintf(1, '\n\n');

%% query with few random documents
tic
[idxs scores]=query(DB, lbls{2}, idf);
toc
fprintf(1, 'Ordering with query #2: '); fprintf(1, '%d ', idxs(1:10)); fprintf(1, '\n');
fprintf(1, 'Scores with query #2: '); fprintf(1, '%f ', scores(1:10)); fprintf(1, '\n\n');

[idxs scores]=query(DB, lbls{18}, idf);
fprintf(1, 'Ordering with query #18: '); fprintf(1, '%d ', idxs(1:10)); fprintf(1, '\n');
fprintf(1, 'Scores with query #18: '); fprintf(1, '%f ', scores(1:10)); fprintf(1, '\n\n');

[idxs scores]=query(DB, lbls{30}, idf);
fprintf(1, 'Ordering with query #30: '); fprintf(1, '%d ', idxs(1:10)); fprintf(1, '\n');
fprintf(1, 'Scores with query #30: '); fprintf(1, '%f ', scores(1:10)); fprintf(1, '\n\n');
