%Convolutional Neural Network I.  (test script)

%% Init MatConvNet
MatConvNet_path = 'dep/matconvnet-1.0-beta17/matlab/';
run([MatConvNet_path, 'vl_setupnn.m']) 
addpath dep

%compile matconvnet if necessary
D = dir([MatConvNet_path, 'mex/*.',mexext]) 
if isempty(D)
    fprintf('MatConvNet does not seem to be compiled. Compiling now...\n')
    vl_compilenn;
    fprintf('Compilation Done.\n\n');
end

%% Load pre-trained CNN model
model = 'imagenet-vgg-f' ;
net = load(sprintf('models/%s.mat', model)) ;

%display net structure
vl_simplenn_display(net)

%display filters
figure(1);
filter_img = vl_imarraysc(net.layers{1}.weights{1});
imagesc(filter_img); 
title('First layer filters')


%% Image classification 
I = imread('grocery.jpg');

%other included images: 
% airport1.jpg, dog_and_cat.jpg, kitchen1.jpg, living_room1.jpg, pc1.jpg,
% street2.jpg

figure(2); 
imagesc(I); axis image
title('Input image')

%normalize image
im = imresize(I, net.meta.normalization.imageSize(1:2));
im = single(im) - net.meta.normalization.averageImage;

%run network
res = vl_simplenn(net, im, [], [], 'mode', 'test');

figure(3); 
input_img = res(1).x; 
m = min(input_img(:)); M = max(input_img(:)); 
imagesc((input_img-m)/(M-m)); axis image
title('Input normalized image'); 

figure(4); 
res2_img =  vl_imarraysc(res(2).x);
imagesc(res2_img); axis image
title('Responses of 1st layer filters');

figure(5);
res3_img =  vl_imarraysc(res(3).x);
imagesc(res3_img); axis image
title('Responses of 1st layer filters after ReLu');


%gather results
r = squeeze(gather(res(end).x));
[rs, id] = sort(r, 'descend');

fprintf('\n');
for i=1:5
    fprintf('%.3f %s \n', rs(i), net.meta.classes.description{id(i)});
end
fprintf('\n');

%% Scanning-window detection 

min_size = floor(max(size(I))/10);
stride = min_size*0.5;

tic, fprintf('Generating scanning window bounding boxes...');
[bboxes, pos] = scanning_windows(I, min_size, stride, 1.5); toc

tic, fprintf('Collecting images into the batch...');
imgs = get_image_batch_from_bboxes(I, bboxes, 224); toc

imgs = bsxfun(@minus, imgs, net.meta.normalization.averageImage); 

tic, fprintf('Executing the convolutional network...')
res = vl_simplenn(net, single(imgs), [], [], 'mode', 'test');
t=toc; fprintf('(%.1f Hz) ', size(imgs,4)/t);  toc
R = squeeze(gather(res(end).x));

[scores,class_ids] = max(R,[],1);

%display all above a threshold
ind = find(scores>0.5);

scores_ = scores(ind);
class_ids_ = class_ids(ind);
bboxes_ = bboxes(:, ind);

figure(6); clf; 
imagesc(I); axis image; hold on
H = show_detections(bboxes_, scores_, class_ids_, net.meta.classes.description); 
title('Scanning window detections')

%% Scanning windows - show response map for a particular class on multiple levels

class_id = find(cellfun('length', strfind(net.meta.classes.description, 'ananas')))
class_name = net.meta.classes.description{class_id}
if isempty(class_id)
    error('Class name was not found');
end
if length(class_id)>1,
    net.meta.classes.description{class_id}
    error('Ambiguous class name');
end

R1 = R(class_id, :); 

levels = max(pos(3,:));
for l=1:levels;
    map = [];
    level_mask = pos(3,:)==l;
    pos_ = pos(1:2,level_mask);
    R1_ = R1(level_mask);
    for i=1:size(pos_,2)
        map(pos_(1,i), pos_(2,i)) = R1_(i);
    end
    maps{l} = map;
end

c1 = min(R1);
c2 = max(R1);

figure(7); clf;
for l=0:levels
    figure(7); 
    subplot(2, floor((levels+1)/2), l+1);
    if l==0
        imagesc(I); axis image
    else
    imagesc(maps{l}); colormap(jet); set(gca, 'clim', [0, 1]); axis image
    title(sprintf('level=%i', l)); 
    end
    axis off
end
set(gcf, 'name', sprintf('Response map, class=''%s'' ', class_name)); 

%% EgeBoxes

addpath dep/edges-master

model=load('dep/edges-master/models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

% detect Edge Box bounding box proposals (see edgeBoxes.m)
fprintf('\n')
tic, fprintf('Generating EdgeBoxes...')
bbs=edgeBoxes(I,model,opts); toc

bboxes = double([bbs(:,1), bbs(:,2), bbs(:,1)+bbs(:,3), bbs(:,2)+bbs(:,4)]');

NumBoxes = 500;

%generate a stack of size-normalized images from bounding boxes
tic, fprintf('Collecting images into the batch...');
imgs = get_image_batch_from_bboxes(I, bboxes(:, 1:NumBoxes), 224); toc

%substract average image
imgs = bsxfun(@minus, imgs, net.meta.normalization.averageImage); 

%execute CNN
tic, fprintf('Executing the convolutional network...')
res = vl_simplenn(net, single(imgs), [], [], 'mode', 'test'); 
t=toc; fprintf('(%.1f Hz) ', size(imgs,4)/t);  toc
R = squeeze(gather(res(end).x));

[scores,class_ids] = max(R,[],1);

%display all above a threshold
ind = find(scores>0.5);

scores_ = scores(ind);
class_ids_ = class_ids(ind);
bboxes_ = bboxes(:, ind);

figure(8); clf; 
imagesc(I); axis image; hold on
H = show_detections(bboxes_, scores_, class_ids_, net.meta.classes.description); 
title('EdgeBoxes detections (all)')


%% Stable detection - remove overlapping detections with lower score

overlap_thr = 0.1 %intersection over union ratio

tic, fprintf('Finding stable detection subset...'); 
idx = stable_detections(scores_, bboxes_, overlap_thr); toc

scores_ = scores_(idx);
class_ids_ = class_ids_(idx);
bboxes_ = bboxes_(:, idx);

figure(9); clf; 
imagesc(I); axis image; hold on
H = show_detections(bboxes_, scores_, class_ids_, net.meta.classes.description); 

title('EdgeBoxes detections (non-overlapping)')


