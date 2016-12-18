clear;
close all;
num = 300;
classProb = [0.3, 0.7];
variance = 0.01;
[pts, lbls] = GenerateData(num, classProb, variance);
PlotData(pts, lbls, 'Orig Data');
[kmeansindx] = kmeans(pts, 2);
figure;
PlotData(pts, kmeansindx, 'K-means');
acc = Purity(kmeansindx, lbls);
fprintf('K-means accuracy - %f\n', acc);

est_noise = 0.3;
normalize = 1;
%%
%Naive
S = CalcSimMatrix(pts, est_noise);
W =S;
L = CalcLaplacian(W, normalize);
[s1indx] = kmeans(L, 2);
figure;
PlotData(pts, s1indx, 'Naive Spectral Clustering');
accs1 = Purity(s1indx, lbls);
fprintf('Naive Spectral accuracy - %f\n', accs1);
%%
S = CalcSimMatrix(pts, est_noise);
epsilon = 0.5;
W =BuildEpsilonGraph(S, epsilon);
L = CalcLaplacian(W, normalize);
[s2indx] = kmeans(L, 2);
figure;
PlotData(pts, s2indx, 'Epsilon Spectral Clustering');
accs2 = Purity(s2indx, lbls);
fprintf('Epsilon Spectral accuracy - %f\n', accs2);
%%
S = CalcSimMatrix(pts, est_noise);
knn = 13;
W = BuildKNNGraph(S,knn);
figure;
PlotGraph(pts, W, 'KNN Graph');
L = CalcLaplacian(W, normalize);
[s3indx] = kmeans(L, 2);
figure;
PlotData(pts, s3indx, 'KNN Spectral Clustering');
accs3 = Purity(s3indx, lbls);
fprintf('KNN Spectral accuracy - %f\n', accs3);

%%
%1] Partition graph into n clusters by cut, but we prefer to have similar
%sizes of cluster/partitions so we introduce normalize cut, which weighs
%cut by sizes of clusters => NP-hard
%
%Similarity with standard k-means. Can be interpreted as weighted
%k-means
%
%2]
%Matrix Generation N^2 (M*N) // poèet jedné komponenty * poèet druhé
%komponenty
%Laplacian N^3 //Eigen
%K-means Normally O(N^2) //Matlab uses "Tall array"