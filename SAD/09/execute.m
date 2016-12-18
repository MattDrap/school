%% Load the word2vec data of synonyms
X = load('data.csv'); % the 300-dimensional data
labels = textread('labels.txt', '%s', 'delimiter', '\n'); % words
colors = load('colors.csv'); % one class = set of synonymous words

%% Optional: Visualize by the first 2 dimensions
figure(1);
plotpoints(X, labels, colors);

%% Plain PCA
figure(2);
pcb = mypca(X, 2);
plotpoints(pcb, labels, colors);

%% ISO-MAP
%figure(2);
%iso = isomap(X, 2, 8);
%plotpoints(iso, labels, colors);

%% t-SNE 
figure(3);
sne = tsne(X, [], 2, 30, 30);
plotpoints(sne, labels, colors);

%% Measure prediction accuracy on low-dimensional data

% random permutation of the original data
perm = randperm(size(X,1));
% perm contains permuted indicies => use them to shuffle the matrices
disp('Accuracy of regression trees on...');
disp(['  original data:            ' num2str(100 * classify(X(perm,:), colors(perm,:)))   '%']);
disp(['  plain PCA processed data: ' num2str(100 * classify(pcb(perm,:), colors(perm,:))) '%']);
%disp(['  ISO-MAP processed data:   ' num2str(100 * classify(iso(perm,:), colors(perm,:))) '%']);
disp(['  t-SNE processed data:     ' num2str(100 * classify(sne(perm,:), colors(perm,:))) '%']);
