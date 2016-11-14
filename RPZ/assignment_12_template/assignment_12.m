% ---------------- Assignment 12 ----------------- %
% --------- Principal Component Analysis --------- %

%% Load data
load data_33rpz_pca.mat
im_size = size(trn_data.images(:,:,1));

%% Prepare data for PCA
[X X_mean] = prepare_data(trn_data.images);

%% Principal component orthogonal basis
[Y lambdas] = pca_basis(X);

%% Display eigenvectors (eigenfaces)
disp_eigenfaces(Y, im_size);

%% Plot the cumulative sum of eigenvalues
sum_eigenvalues_graph(lambdas);

%% Experiments with different m values
sel_image = 1;
num_comp = size(Y,2);
Z_im = zeros([im_size 1 num_comp]);
class_error = zeros(1, num_comp);
% Prepare labels
names_unique = unique(trn_data.names);
[~, labels_trn] = ismember(trn_data.names, names_unique);
[~, labels_tst_gt] = ismember(tst_data.names, names_unique);

for m = 1:num_comp

    % Compact representation of the images
    W_trn = compact_representation(X, Y, m);

    % Reconstruct the images (approximation)
    Z = reconstruct_images(W_trn, Y, X_mean);
    
    % Store images
    Z_im(:,:,1,m) = reshape(Z(:,sel_image),im_size);
    
    % NN classifier
    [labels_tst] = classify_nn_pca(tst_data.images, Y, X_mean, W_trn, labels_trn, m);
    
    % Classification error
    class_error(m) = sum(labels_tst_gt~=labels_tst)/numel(labels_tst_gt);
    
end
    
%% Display the images
figure, montage(uint8(Z_im));

%% Plot the classification error vs the number of components
figure, plot(class_error), grid on;
xlabel 'Number of components'
ylabel 'Classification error'