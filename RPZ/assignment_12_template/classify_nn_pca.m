%
% [labels_tst] = classify_nn_pca(images, Y_trn, X_trn_mean, W_trn, labels_trn, m)
%
% Function for classification by nearest neightbor search in the
% reduced-representation space
%
% Input:
%       images - Stack of images to be classified, of size [width, height, number_of_images]
%       Y_trn - Set of principal components computed from the training
%       data, of size [width*height, number_of_training_images]
%       X_trn_mean - Mean vectorized image of the training set, of size [width*height, 1]
%       W_trn - Compact representation of the training images, of size [m, number_of_training_images]
%       labels_trn - Set of labels of the training images, of size [1, number_of_training_images]
%       m - Number of components to be used for the approximation, of size [1, 1]
% Output:
%       labels_tst - Set of labels (integers) of the training images
%

function [labels_tst] = classify_nn_pca(images, Y_trn, X_trn_mean, W_trn, labels_trn, m)

    % Prepare testing data
    [width, height, number_of_training_images] = size(images);
    images = reshape(images, width*height, number_of_training_images);
    % HERE YOUR CODE
    images = double(images);
    images = images - repmat(X_trn_mean, 1, number_of_training_images);
    Im = compact_representation(images, Y_trn, m);
    labels_tst = zeros(1, number_of_training_images);
    for i = 1:number_of_training_images
        D = W_trn - repmat(Im(:, i), 1, size(Y_trn, 2));
        D = sum(D.^2, 1);
        [dist, idc] = min(D);
        labels_tst(i) = labels_trn(idc);
    end
end
