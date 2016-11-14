%Convolutional Neural Network II.  (test script)

%% Init MatConvNet
MatConvNet_path = './dep/matconvnet-1.0-beta17/matlab/';
run([MatConvNet_path, 'vl_setupnn.m']) 
addpath ./dep

%compile matconvnet if necessary
D = dir([MatConvNet_path, 'mex/*.',mexext]);
if isempty(D)
    fprintf('MatConvNet does not seem to be compiled. Compiling now...\n')
    vl_compilenn;
    fprintf('Compilation Done.\n\n');
end


%% laod data and show samples

imdb = load('mnist/imdb.mat') ;

%limit the amount of training data (to speed the training up)
max_trn_samples = 15000; %increase for better results
tr_ix = find(imdb.images.set == 1);
imdb.images.set(tr_ix(max_trn_samples+1:end)) = 0;

% Visualize some of the hand-written digit data
figure(1) ; clf ; colormap gray ;
subplot(1,2,1) ;
vl_imarraysc(imdb.images.data(:,:,imdb.images.labels==8 & imdb.images.set==1)) ;
axis image off ;
title('all training samples for ''7''') ;

subplot(1,2,2) ;
vl_imarraysc(imdb.images.data(:,:,imdb.images.labels==8 & imdb.images.set==2)) ;
axis image off ;
title('all validation samples for ''7''') ;

%% The network for in-context rocognition including space - training

% Add "space" character to capture blank space
imdb.images.data(:,:,:,end:end+5000) = 0;
imdb.images.labels(end:end+5000) = 11;
imdb.images.set(end:end+3000) = 1;
imdb.images.set(end:end+2000) = 2;
imdb.meta.classes{end+1} = ' '

net = cnn_mnist_init('num_classes', 11);  %one more class added
vl_simplenn_display(net);

trainOpts = [];
trainOpts.batchSize = 100 ;
trainOpts.numEpochs = 100 ;
trainOpts.continue = true ;
trainOpts.learningRate = 0.001 ;
trainOpts.expDir = 'mnist/context' ;

% Call training function in MatConvNet
[net,info] = cnn_train(net, imdb, @getBatchWithContext, trainOpts) ;

%%  The network for in-context rocognition including space - testing

% load the network with the lowest validation error
[val_err, ix] = min(info.val.error(1,:))
load([trainOpts.expDir, '/net-epoch-', num2str(ix)]);
net.layers{end}.type = 'softmax'; %softmax loss -> softmax (for testing)

%generate a stack of all 28x28 subwindows
N = size(I,2) - 28;
img = single(zeros(28, 28, 1, N));
bboxes = zeros(4,N);
for i=1:N
	img(:,:,1,i) = I(:, i:27+i);
	bboxes(:,i) = [i,1,27+i,28];
end
res = vl_simplenn(net, single(img), [], [], 'mode', 'test');
scores = squeeze(gather(res(end).x));
[s, labels] = max(scores,[],1); 

%visualize the results
figure(7); clf;
cmap = jet(11);
imagesc(I); axis image; colormap gray; hold on; ha1 = gca; axis off
title('input image'); 
for i=1:N,
	hh = text(0.5*(bboxes(1,i)+bboxes(3,i)), bboxes(4,i)+5, imdb.meta.classes(labels(i)) );
	set(hh, 'color', cmap(labels(i),:)); 
	set(hh, 'parent', ha1);
end
ha2 = axes; pos = get(ha1, 'position'); 
set(ha2, 'position', [pos(1), 0.2, pos(3), 0.15]);
hh = plot(0.5*(bboxes(1,:)+bboxes(3,:)), s, 'o-'); hold on;
set(hh, 'parent', ha2); ylim([0,1]); 
xlim([0,size(I,2)]); ylabel('max score'); grid on
title('max scores and argmax labels')
ha3 = axes; 
set(ha3, 'position', [pos(1), 0.7, pos(3), 0.15]);
Z = NaN(size(scores,1),14);
Simg = ind2rgb(uint8([Z,double(scores),Z]*255), jet);  %response map
imagesc(Simg);
set(gca, 'ytick', 1:11); set(gca, 'yticklabel', imdb.meta.classes); grid on
ylabel('labels'); 
title('response map');
set(gcf, 'name', 'In-context-network'); 

% Context error of the "in-context" network 
res = vl_simplenn(net, single(Contextdb.imgs), [], [], 'mode', 'test');
scores = squeeze(gather(res(end).x));
[s, labels_] = max(scores,[],1); 
context_error_cntx = sum(labels_ ~= Contextdb.labels) / length(Contextdb.labels) 


% Isolated error of the "in-context" network
imgs = imdb.images.data(:,:,1,imdb.images.set==2);
labels = imdb.images.labels(imdb.images.set==2);
res = vl_simplenn(net, single(imgs), [], [], 'mode', 'test');
scores = squeeze(gather(res(end).x));
[s, labels_] = max(scores,[],1); 
isolated_error_cntx = sum(labels_ ~= labels) / length(labels) 


%% display the error statistics

fprintf('--------------------------------------------------\n'); 
fprintf('|                | Net-baseline | Net-in-context |\n');
fprintf('-------------------------------------------------\n'); 
fprintf('| Isolated error |    %.3f     |     %.3f      |\n', isolated_error_baseline, isolated_error_cntx); 
fprintf('| Context error  |    %.3f     |     %.3f      |\n', context_error_baseline, context_error_cntx);
fprintf('--------------------------------------------------\n'); 

