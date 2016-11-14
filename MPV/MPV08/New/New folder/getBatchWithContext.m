function [im, labels] = getBatchWithContext(imdb, batch)
%GETBATCHWITHCONTEX - provides a batch of images nad labels for in-context training
%
%   imdb - structure of the dataset (images and labels)
%   batch - (1xK) list of indexes into imdb.images.data and imdb.images.labels
%   
%   im - stack of images (28x28x1xK)
%   labels - corresponding labels (1xK)
%
% see also: GetBatch 
%
K = size(batch, 2);
preim = imdb.images.data(:,:,:,batch);
labels = imdb.images.labels(1,batch);
im = preim;
for i = 1:K
    ind1 = floor(rand()*(K-1) + 1);
    ind2 = floor(rand()*(K-1) + 1);
    rim1 = preim(:, :, ind1);
    rim2 = preim(:, :, ind2);
   
    rmargin1 = floor(rand()*8 + 1);
    rmargin2 = floor(rand()*8 + 19);
    
    imc = preim(:, :, i);
    
    imc(:, rmargin2:end) = imc(:, rmargin2:end) + rim2(:, rmargin2:end);
    imc(:, 1:rmargin1) = imc(:, 1:rmargin1) + rim1(:, 1:rmargin1);
    im(:, :, i) = imc;
end