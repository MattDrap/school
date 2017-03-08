%% Set paths
clear all;
addpath('./CNN'); % CNN code
addpath('./minFunc'); % optimizer
addpath('./autoencoder'); % Auto-encoder
addpath('./data'); % Data folder
addpath('./misc'); % Misc functions
addpath('./softmax'); % softmax classifier

%% Load train and test data
% To demonstrate the code we use images from the Sift Flow [1] data set 
%
% [1] C. Liu, J. Yuen, and A. Torralba, “SIFT Flow: Dense Correspondence across 
%     Different Scenes and Its Applications,” IEEE Trans. Pattern Analysis and 
%     Machine Intelligence, vol. 33, no. 5, pp. 978-994, May 2011.


Itrain = imread('czdata.1988187.tif');
ytrain = imread('fmask.1988187.tif');

Ltrain(ytrain == 4) = 1;
Ltrain(ytrain == 2) = 2;
Ltrain(ytrain ~=2 & ytrain ~= 4) = 3;
Ltrain = reshape(Ltrain, size(ytrain));
%Itrain = imread('highway_gre277.jpg');
%ytrain = load('highway_gre277.mat');
%Ltrain = ytrain.S;

% figure;
% subplot(1,2,1); imagesc(Itrain); title('image')
% subplot(1,2,2); imagesc(ytrain.S); title('labels')

% Structure parameters
imageDim = 25; % context area, m.
selectedChannels = [1 2 3 4 5 6];%selectedChannels = [1 2 3]; % Selected color channels, RGB
imageChannels = length(selectedChannels);
labelnames = {'Cloud', 'Shadow', 'Other'}; %labelnames = {'Sky', 'Road', 'Mountain'};
numImagesPerCategory = 1000;
numClasses = length(labelnames);

% Randomly extract images
[images labels indexes] = sampleImages(Itrain(:,:,selectedChannels), imageDim, numImagesPerCategory, Ltrain, numClasses, 1);
images = reshape(images,[],size(images,4));

% figure; imagesc(Ltrain); hold on; 
% [xlist,ylist] = ind2sub(size(Ltrain),indexes); scatter(ylist, xlist, 'kx', 'Sizedata', 5)

% Split into train, val, and test sets
seed = 10;
[trainimages valimages testimages] = split(images,[0.7 0.1 0.2], seed);
[trainlabels vallabels testlabels] = split(labels,[0.7 0.1 0.2], seed);
clear images labels

% Normalize data
trainimages = single(trainimages);
valimages = single(valimages);
testimages = single(testimages);
meanPatch = myupsample(mean(reshape(mean(trainimages, 2),imageDim^2,[]))',imageDim^2);
stdPatch = myupsample(mean(reshape(std(trainimages, [], 2),imageDim^2,[]))',imageDim^2);
trainimages = bsxfun(@rdivide, bsxfun(@minus, trainimages, meanPatch), stdPatch);
valimages = bsxfun(@rdivide, bsxfun(@minus, valimages, meanPatch), stdPatch);
testimages = bsxfun(@rdivide, bsxfun(@minus, testimages, meanPatch), stdPatch);

% Reshape to dim x dim x channels x N
trainimages = reshape(trainimages, imageDim, imageDim, imageChannels, []);
valimages = reshape(valimages, imageDim, imageDim, imageChannels, []);
testimages = reshape(testimages, imageDim, imageDim, imageChannels, []);

%% Train CNN model
% Training set, validation set, and testing set are randomly extracted 
% from the same image.

% CNN parameters
poolDim = 4; % pooling dimension, p
filterDim = 10; % filter dimension, n
numFilters = 50; % number of filters, k
activation = 'relu'; % activation function ['relu' 'sigmoid']
pooling = 'mean'; % pooling function ['mean' 'max]

% k-means parameters
numPatches = 10000; % Number of patches for k-means

% FC-layer Parameters
numhid  = 1000;   % number of hidden units
parameters = []; % parameters for the auto-encoder
parameters.lambda = 3e-5; % Weight decay penalty parameter
parameters.beta = 0;      % Sparsity penalty parameter
parameters.p = 0.2;       % desired sparsity activation
parameters.L1 = 1e-4;     % L1 penalty on hidden layer activation
parameters.activation = {'relu', 'linear'}; % activation function
parameters.useGPU = 0;       % use GPU in inner loop
parameters.useDenoising = 1; % use denoising auto-encoder
parameters.useDropout = 1; % use dropout
options = []; % parameters for the optimizer
options.numepochs = 100;
options.batchsize = 10;
options.learningRate = 1e-4;
options.useMomentum = 1;
options.useGPU = 0;          % use GPU in outer loop
options.useDecayLearningRate = 1;
options.plotProgress = 1;

% ================== Learn filter patches  ===================
patches = samplePatches(trainimages, filterDim, numPatches);
w = run_kmeans(patches', numFilters, 100, true);
w = reshape(w', filterDim, filterDim, imageChannels, numFilters);
clear patches
% displayColorNetwork(reshape(w, [], numFilters)) % plot learned filters

% ================== Convolve and pool data ============================
pooledTrain = TrainCNN(trainimages, w, activation, poolDim, pooling, true);
pooledVal = TrainCNN(valimages, w, activation, poolDim, pooling, true);
pooledTest = TrainCNN(testimages, w, activation, poolDim, pooling, true);
pooledTrain = reshape(pooledTrain,[],size(pooledTrain,4));
pooledVal = reshape(pooledVal,[],size(pooledVal,4));
pooledTest = reshape(pooledTest,[],size(pooledTest,4));
clear trainimages testimages valimages

% ================== Train and feedforward through FC-layer =============
numvis = size(pooledTrain, 1);  % number of input units
[theta thetaSize] = initAEParameters(numvis, numhid, 5);
[theta Jtrain Jval] = minFuncSGD(@costAutoencoder, theta, thetaSize, pooledTrain, options, parameters, pooledVal);
[W1 W2 b1 b2] = theta2params(theta, thetaSize);
pooledTrain = sigma(bsxfun(@plus, W1 * pooledTrain, b1), parameters.activation{1});
pooledTest = sigma(bsxfun(@plus, W1 * pooledTest, b1), parameters.activation{1});

% ================== Train Classifier (supervised) ======================
optTheta = softmaxTrain(pooledTrain, trainlabels, 400, 1e-4, 1, numClasses);

% ================== Calculate accuracy =================================
trainAccuracy = 100*mean(softmaxPredict(optTheta, pooledTrain)==trainlabels);
testAccuracy = 100*mean(softmaxPredict(optTheta, pooledTest)==testlabels);
    
% ================== Print results ======================================
fprintf('train acc: %0.2f test acc: %0.2f\n', trainAccuracy, testAccuracy)


%% Use CNN model to perform full image per-pixel classification
% Training set and validation set are randomly extracted from one image and
% all pixels in another image are classified.

% Load test image
Itest = imread('czdata.1988315.tif'); %Itest = imread('highway_gre279.jpg');
Itest = Itest(1000:1255, 1000:1255);
% Normalize image
Itest = single(Itest);
tempmean = reshape(meanPatch,imageDim,imageDim,imageChannels);
tempstd = reshape(stdPatch,imageDim,imageDim,imageChannels);
Itest = bsxfun(@minus, Itest, repmat(tempmean(1,1,:),size(Itest,1),size(Itest,2)));
Itest = bsxfun(@rdivide, Itest, repmat(tempstd(1,1,:),size(Itest,1),size(Itest,2)));

% Convolution
convolved = cnnConvolve(Itest, w);
% Non-linear activation function
convolved = sigma(convolved, activation);
% Reshape to 4D
convolvedDim = imageDim - filterDim + 1;
convolved4D = zeros(convolvedDim, convolvedDim, numFilters, (size(convolved,2)-convolvedDim)*(size(convolved,1)-convolvedDim));
ind = 1;
for i = 1:size(convolved,2)-convolvedDim
    for j = 1:size(convolved,1)-convolvedDim
        convolved4D(:,:,:,ind) = convolved(i:i+convolvedDim-1,j:j+convolvedDim-1,:);
        ind = ind + 1;
    end
end
clear convolved

% LCN
convolved4D = localnorm(convolved4D);
% Pooling
pooled = cnnPool(convolved4D, poolDim, pooling);
pooled = reshape(pooled,[],size(pooled,4));
% Feedforward through FC-layer
pooled = sigma(bsxfun(@plus, W1 * pooled, b1), parameters.activation{1});
% Predict using softmax
[Lpred hpred] = softmaxPredict(optTheta, pooled);
% Reshape
Lpred = reshape(Lpred,231,231)';


%% Use segmentation to clean up predictions
% Copy the SLIC implementation [1] and put the files in a folder called 'slic'
%
% [1] http://www.peterkovesi.com/projects/segmentation/

addpath('./slic');

% Load test image and groundtruth. Crop the image and groundtruth matrix.
Itest = imread('highway_gre279.jpg');
Itest = Itest(ceil(imageDim/2):end-ceil(imageDim/2), ceil(imageDim/2):end-ceil(imageDim/2), :);
ytest = load('highway_gre279.mat');
Ltest = ytest.S;
Ltest = Ltest(ceil(imageDim/2):end-ceil(imageDim/2), ceil(imageDim/2):end-ceil(imageDim/2), :);

% subplot(3,1,1); imagesc(Itest); title('Input data')
% subplot(3,1,2); imagesc(Lpred); title('Predicted label')
% subplot(3,1,3); imagesc(Ltest, [1 3]); title('True label')
% fprintf('Classification accuracy: %0.2f\n', mean(mean(Ltest==Lpred)))

% SLIC segmentation
[S, Am, Sp, d] = slic(Itest, 1000, 10, 1.5, 'mean');

% Make Kindex
Kindex = zeros(size(Lpred));
ind = 1;
for i = 1:size(Lpred,1)
    for j = 1:size(Lpred,2)
        Kindex(i,j) = ind;
        ind = ind + 1;
    end
end

% Average classification over each region
Lpredavg = Lpred;
numRegions = length(unique(S));
for i=1:numRegions
    [~, topC] = max(histc(Lpredavg(S==i),1:numClasses));
    Lpredavg(S==i) = topC;
end

figure; 
subplot(1,3,1); imagesc(drawregionboundaries(S, Itest)); title('Input data and segmentation');
subplot(1,3,2); imagesc(Lpred); title('Predictions before segmentation averaging');
subplot(1,3,3); imagesc(drawregionboundaries(S, Lpredavg)); title('Predictions after segmentation averaging');

%% Use predictions to clean up segmentation

% Make Svec from Ltest, h, and S
% Svec is a matrix with N rows, where N is the number of regions and three 
% columns: predicted class, classification certainty, and true class.
Svec = zeros(length(unique(S)), 3);
for i=1:length(unique(S))
    ind = Kindex(find(S==i & Kindex~=0));
    hregionsum = sum(hpred(:,ind),2)/sum(sum(hpred(:,ind)));
    [Svec(i,2) Svec(i,1)] = max(hregionsum);
    [~, temp] = max(histc(Ltest(S==i),0:numClasses));
    Svec(i,3) = temp - 1;
end

% Merge regions based on certainty. Set new prediction as 
% old prediction + 10 if classification certainty is below a threshold
th = 0.95; % Threshold for region merging [0 1]
Svec(Svec(:,2)<th,1)=Svec(Svec(:,2)<th,1)+10;

% Make Smerged from S and Svec using fill flood
Kavg = zeros(size(S)); % Helper matrix
Smerged = zeros(size(Kavg));
for i=1:length(unique(S))
    Kavg(S==i) = Svec(i,1);
end
rindex = 1;
for k=1:numel(Kavg)
    if Smerged(k)==0
        [i,j]=ind2sub(size(Kavg),k);
        tempK=Kavg;
        tempK(tempK~=tempK(i,j))=0;
        tempK(tempK==tempK(i,j))=1;
        [BW2,IDX] = bwselect(tempK, j, i, 8);
        Smerged(IDX)=rindex;
        rindex = rindex + 1;
    end
end

figure;
subplot(1,2,1); imagesc(drawregionboundaries(S, Itest)); title('Segmentation before merging');
subplot(1,2,2); imagesc(drawregionboundaries(Smerged, Itest)); title('Segmentation after merging');

