function [imgs] = get_image_batch_from_bboxes(I, bboxes, target_size)
%
%  
%   [imgs] = get_image_batch_from_bboxes(I, bboxes, target_size)
%
%    I - input image (HxWx3)
%    bboxes - list of bounding boxes (4xN) [tlx,tly,brx,bry]
%    target_size - target size of the normalized image (224)
%
%    imgs - output normalized batch (target_size x target_size x 3 x N)
%          

N = size(bboxes, 2);
imgs = NaN(target_size, target_size, 3, N);

for i=1:N
    bb = bboxes(:,i);
    im_crop = I(bb(2):bb(4),bb(1):bb(3),:);
    imgs(:,:,:,i) = imresize(im_crop, [target_size, target_size]);
end

