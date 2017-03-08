function pooled = TrainCNN(images, filters, activation, poolDim, pooling, verbose)
% Trains a layer of CNN (convolution -> activation function -> pooling ->
% local contrast normalization). Uses patching to large image before
% convolution to speed up training. 
%
% INPUTS:
%   images: 4-D matrix (imageDim, imageDim, imageChannels, numImages)
%   filters: 4D filters
%   activataion: 'sigmoid' or 'relu'
%   poolDim: pooling dimension, p
%   verbose: Print progress
% OUTPUT:
%   pooled: 4D pooling layer

if nargin < 6
    verbose = 0;
end

imageDim = size(images, 1);
numImages = size(images,4);

%nx = ceil(sqrt(size(images,4)));
nx = 50; %make large image of nx-by-nx patches
nx2 = nx^2;
filterDim = size(filters,1);
convolvedDim = imageDim - filterDim + 1;

% Pre-allocate matrix
%convolved = zeros(convolvedDim,convolvedDim, size(filters,1), numImages, class(images));
pooled = zeros(convolvedDim/poolDim, convolvedDim/poolDim, size(filters,4), numImages, class(images));

% Assertions
assert(mod(nx,1)==0, 'cnnConvolvePatching: Number of patches is not a square number')
assert(mod(convolvedDim/poolDim,1)==0, 'convolvedDim/poolDim: Division not an integer')

% Do nx2 images at a time to speed up training
for i=1:floor(numImages/nx2)
    % Patches->Image
    patchImage = patches2image(images(:,:,:,1+(i-1)*nx2:i*nx2));
    % CNN whole image
    convolvedImage = cnnConvolve(patchImage, filters);
    clear patchImage
    % Remove overlap rows, cols
    rind = (convolvedDim + 1)+(0:nx-2)'*imageDim;
    rind = bsxfun(@plus,repmat(rind,1, filterDim-1), 0:filterDim-2);
    rinv = ones(convolvedDim*nx+(nx-1)*(filterDim-1),1);
    rinv(rind) = 0;
    rinv = find(rinv==1);
    convolvedImage = convolvedImage(rinv,rinv,:);
    % Image->Patches
    convolved = image2patches(convolvedImage, convolvedDim, convolvedDim);
    clear convolvedImage
    % Non-linear activation function
    convolved = sigma(convolved, activation);
    % LCN
    convolved = localnorm(convolved);
    % Pooling
    pooled(:,:,:,1+(i-1)*nx2:i*nx2) = cnnPool(convolved, poolDim, pooling);
    clear convolved
    if verbose
        fprintf('Images processed: %i/%i\n', i*nx2, numImages)
    end
end

% Do one more large image
if floor(numImages/nx2)*nx2<numImages
    nx = floor(sqrt(numImages - floor(numImages/nx2)*nx2));
    % Patches->Image
    patchImage = patches2image(images(:,:,:,floor(numImages/nx2)*nx2+1:floor(numImages/nx2)*nx2+nx*nx));
    % CNN whole image
    convolvedImage = cnnConvolve(patchImage, filters);
    clear patchImage
    % Remove overlap rows, cols
    rind = (convolvedDim + 1)+(0:nx-2)'*imageDim;
    rind = bsxfun(@plus,repmat(rind,1, filterDim-1), 0:filterDim-2);
    rinv = ones(convolvedDim*nx+(nx-1)*(filterDim-1),1);
    rinv(rind) = 0;
    rinv = find(rinv==1);
    convolvedImage = convolvedImage(rinv,rinv,:);
    % Image->Patches
    convolved = image2patches(convolvedImage, convolvedDim, convolvedDim);
    clear convolvedImage
    % Non-linear activation function
    convolved = sigma(convolved, activation);
    % LCN
    convolved = localnorm(convolved);
    % Pooling
    pooled(:,:,:,floor(numImages/nx2)*nx2+1:floor(numImages/nx2)*nx2+nx*nx) = cnnPool(convolved, poolDim, pooling);
    if verbose
        fprintf('Images processed: %i/%i\n', floor(numImages/nx2)*nx2+nx*nx, numImages)
    end
    clear convolved
end

% Do 1 image at a time for the rest
for i=floor(numImages/nx2)*nx2+nx*nx+1:numImages
    % Convolution
    convolved = cnnConvolve(images(:,:,:,i), filters);
    % Non-linear activation function
    convolved = sigma(convolved, activation);
    % LCN
    convolved = localnorm(convolved);
    % Pooling
    pooled(:,:,:,i) = cnnPool(convolved, poolDim, pooling);
    if verbose
        fprintf('Images processed: %i/%i\n', i, numImages)
    end
end


end